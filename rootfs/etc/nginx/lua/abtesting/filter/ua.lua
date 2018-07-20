local _M = {}
local string = require 'string'
local operator = require("abtesting.lib.operator")

function _M.get()
    return ngx.var.http_user_agent
end

function _M.check_rule(params)
    local get_args = params['get_args']
    local op, op_args = params['op'], params['op_args']
    if get_args ~= nil then
        return "ua rule's get argument must be nil"
    end
    local err = operator.validate_op_args(op, op_args)
    if err ~= nil then
        return err
    end
end

function _M.process(params)
    local ua = ngx.var.http_user_agent
    if not ua then
        return false, nil
    end
    local op, op_args = params['op'], params['op_args']

    local ua = string.lower(ua)
    return operator[op](ua, op_args)
end

return _M