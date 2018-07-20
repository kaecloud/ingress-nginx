local _M = {}

local string = require 'string'
local cjson = require 'cjson'

local config = require 'abtesting.core.config'
local processor = require 'abtesting.core.processor'

local rules = {}
local rules_shdict = ngx.shared.rules

-- measured in seconds
-- for an Nginx worker to pick up the new list of ABTesting RULES
-- it will take <the delay until controller POSTed the rules object to the Nginx endpoint> + RULES_SYNC_INTERVAL
local RULES_SYNC_INTERVAL = 1
--[[
rule: {
    "init": "r1",
    "rules": {
        "r1": {
            "args": {
                "fail": "r3",
                "pattern": "httpie(\\\\S+)$",
                "succ": "r4"
            },
            "type": "ua"
        },
        "r2": {
            "args": {
                "servername": "127.0.0.1:8088"
            },
            "type": "backend"
        },
        "r3": {
            "args": {
                "servername": "127.0.0.1:8089"
            },
            "type": "backend"
        },
        "r4": {
            "args": {
                "regex": true,
                "pattern": "^\\\\/blog\\\\/(\\\\S+)$",
                "succ": "r2",
                "fail": "r3",
            },
            "type": "header"
        }
    }
}
-- ]]

local function sync_rules()
    local raw_data = rules_shdict:get(config.RULES_KEY)
    if raw_data ~= nil then
        rules = cjson.decode(raw_data)
    end
end

function _M.init_worker()
    sync_rules() -- when worker starts, sync backends without delay
    local _, err = ngx.timer.every(RULES_SYNC_INTERVAL, sync_rules)
    if err then
        ngx.log(ngx.ERR, string.format("error when setting up timer.every for sync_rules: %s", tostring(err)))
    end
end

function _M.route()
    ngx.log(ngx.DEBUG, "*******" .. ngx.var.proxy_upstream_name)
    local default_backend = ngx.var.proxy_upstream_name
    local key = ngx.var.host
    local rule = rules[key]
    if rule == nil then
        -- ngx.exit(ngx.HTTP_NOT_FOUND)
        return default_backend
    end
    local backend, err_code = processor.process(rule)
    if err_code ~= nil then
        ngx.exit(err_code)
    end
    if backend == "{DEFAULT}" then
        backend = default_backend
    elseif backend == "{CANARY}" then
        -- contruct canary backend
        backend = string.format("%s-%s-canary-%s", ngx.var.namespace, ngx.var.service_name, ngx.var.service_port)
        ngx.var.proxy_upstream_name = backend
    else
        ngx.var.proxy_upstream_name = backend
    end
    -- if backend == nil then
    --     ngx.exit(ngx.HTTP_NOT_FOUND)
    -- end
    ngx.log(ngx.DEBUG, "+++++++" .. ngx.var.proxy_upstream_name)
    return backend
end

return _M