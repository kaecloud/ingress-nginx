local _M = {}

local operator = require("abtesting.lib.operator")

function _M.get(name)
    local u = ngx.req.get_uri_args()[name]
    return u
end

function _M.check_rule(params)
    local get_args = params['get_args']
    local op, op_args = params['op'], params['op_args']
    if type(get_args) ~= "string" then
        return "query rule's get argument must be a string"
    end
    local err = operator.validate_op_args(op, op_args)
    if err ~= nil then
        return err
    end
end

function _M.process(params)
    local get_args = params['get_args']

    local req_info = _M.get(get_args)
    local op, op_args = params['op'], params['op_args']
    return operator[op](req_info, op_args)
end

return _M
