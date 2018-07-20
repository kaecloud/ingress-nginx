local _M = {}
local string = require("string")

function _M.validate_op_args(op, op_args)
    if op == "equal" or op == "not_equal" then
        if not (type(op_args) == "number" or type(op_args) == "string") then
            return string.format("%s op's argument must be a number or string", op)
        end
    elseif op == "regex" or op == "not_regex" then
        if type(op_args) ~= "string" then
            return string.format("%s op's argument must be a string", op)
        end
    elseif op == "range" or op == "not_range" then
        if type(op_args) ~= "table" then
            return string.format("%s op's argument must be a table", op)
        end
        if type(op_args["start"]) ~= type(op_args["end"]) then
            return "value of start and end must be same type"
        end
        if op_args["start"] == nil or op_args["end"] == nil then
            return "argument for `range` op must contain `start` and `end`"
        end
        if op_args["start"] >= op_args["end"] then
            return string.format("left bound is bigger than right bound")
        end
    elseif op == "oneof" or op == "not_oneof" then
        if type(op_args) ~= "table" then
            return string.format("%s op's argument must be an array")
        end
    else
        return string.foramt("unkown op %s", op)
    end
    return nil
end

function _M.equal(arg, op_arg)
    return arg == op_arg, nil
end

function _M.not_equal(arg, op_arg)
    return arg ~= op_arg, nil
end

function _M.regex(arg, op_arg)
    local pattern = op_arg
    local captured, err = ngx.re.match(arg, pattern)
    if err or not captured then
        return false, err
    end
    return true, nil
end

function _M.not_regex(arg, op_arg)
    local ret, err =  _M.regex(arg, op_arg)
    return (not ret), err
end

function _M.range(arg, op_arg)
    local start = op_arg["start"]
    local end_ = op_arg["end"]
    if arg < start or arg >= end_ then
        return false, nil
    end
    return true, nil
end

function _M.not_range(arg, op_arg)
    local ret, err = _M.range(arg,  op_arg)
    return (not ret), err
end

-- op_args must be an array
function _M.oneof(arg, op_args)
    for i = 1, #op_args do
        local op_arg = op_args[i]
        if arg == op_arg then
            return true, nil
        end
    end
    return false, nil
end

function _M.not_oneof(arg, op_args)
    local ret, err = _M.oneof(arg, op_args)
    return (not ret), err
end

return _M
