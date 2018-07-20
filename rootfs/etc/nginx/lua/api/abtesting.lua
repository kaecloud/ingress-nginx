local _M = {}

local cjson = require 'cjson'
local utils = require 'abtesting.lib.utils'
local config = require 'abtesting.core.config'
local string = require 'string'
local rules_shdict = ngx.shared.rules

local function validate_rule(rule)
    local init = rule["init"]
    local inner_rules = rule["rules"]
    if inner_rules[init] == nil then
        return
    end
    for phase, r in pairs(inner_rules) do
        local ty = r["type"]
        local args = r["args"]
        if ty == "backend" then
            if args["servername"] == nil then
                return "argument must contain servername for `backend` rule"
            end
        else
            local mod = config.filters[ty]
            if mod == nil then
                return string.format("unknown rule type %s", ty)
            end

            local err = mod.check_rule(args)
            if err ~= nil then
                return err
            end
        end
    end
    return nil
end

local function detail()
    local result = rules_shdict:get(config.RULES_KEY)
    ngx.say(result)
    ngx.exit(ngx.HTTP_OK)
end

local function post()
    local data = utils.read_data()
    local domains = cjson.decode(data)
    for domain, rule in pairs(domains) do
        -- validate the rules
        local err = validate_rule(rule)
        if err ~= nil then
            ngx.say(err)
            ngx.exit(ngx.HTTP_BAD_REQUEST)
        end
    end
    -- because validate_rules may change the content of the data,
    -- so we need encode again
    rules_shdict:set(config.RULES_KEY, cjson.encode(domains))
    utils.say_msg_and_exit(ngx.HTTP_OK, "OK")
end

local function delete()
    -- local data = utils.read_data()
    -- local domains = cjson.decode(data)
    -- for i = 1, #domains do
    --     local domain = domains[i]
    --     local key = string.format(config.DOMAIN_KEY, config.NAME, domain)
    --     rules:delete(key)
    -- end
    rules_shdict:delete(config.RULES_KEY)
    utils.say_msg_and_exit(ngx.HTTP_OK, "OK")
end

function _M.call()
    if ngx.var.request_method == 'GET' then
        detail()
    elseif ngx.var.request_method == 'POST' then
        post()
    elseif ngx.var.request_method == 'DELETE' then
        delete()
    else
        utils.say_msg_and_exit(ngx.HTTP_FORBIDDEN, "")
    end
end

return _M
