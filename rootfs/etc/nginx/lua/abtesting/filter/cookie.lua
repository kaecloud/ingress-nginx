local _M = {}

local operator = require("abtesting.lib.operator")

function _M.check_rule(params)
    local get_args = params['get_args']
    local op, op_args = params['op'], params['op_args']
    if type(get_args) ~= "string" then
        return "cookie rule's get argument must be a string"
    end
    local err = operator.validate_op_args(op, op_args)
    if err ~= nil then
        return err
    end
end

function _M.get(cookie_name)
    local var_name = "cookie_" .. cookie_name
    local cookie_value = ngx.var[var_name]
    return cookie_value
end

function _M.process(params)
    local get_args = params['get_args']

    local req_info = _M.get(get_args)
    local op, op_args = params['op'], params['op_args']
    return operator[op](req_info, op_args)
end

return _M
