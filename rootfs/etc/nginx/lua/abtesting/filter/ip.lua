local _M = {}
local string = require 'string'
local ffi = require("ffi")
local operator = require("abtesting.lib.operator")

ffi.cdef[[
struct in_addr {
    uint32_t s_addr;
};

int inet_aton(const char *cp, struct in_addr *inp);
uint32_t ntohl(uint32_t netlong);

char *inet_ntoa(struct in_addr in);
uint32_t htonl(uint32_t hostlong);
]]

local C = ffi.C

local ip2long = function(ip)
    local inp = ffi.new("struct in_addr[1]")
    if C.inet_aton(ip, inp) ~= 0 then
        return tonumber(C.ntohl(inp[0].s_addr))
    end
    return nil
end

local long2ip = function(long)
    if type(long) ~= "number" then
        return nil
    end
    local addr = ffi.new("struct in_addr")
    addr.s_addr = C.htonl(long)
    return ffi.string(C.inet_ntoa(addr))
end

function _M.get()
    local ClientIP = ngx.req.get_headers()["X-Real-IP"]
    if ClientIP == nil then
        ClientIP = ngx.req.get_headers()["X-Forwarded-For"]
        if ClientIP then
            local colonPos = string.find(ClientIP, ' ')
            if colonPos then
                ClientIP = string.sub(ClientIP, 1, colonPos - 1)
            end
        end
    end
    if ClientIP == nil then
        ClientIP = ngx.var.remote_addr
    end
    if ClientIP then
        ClientIP = ip2long(ClientIP)
    end
    return ClientIP
end

function _M.check_rule(params)
    local get_args = params['get_args']
    local op, op_args = params['op'], params['op_args']
    if get_args ~= nil then
        return "ip rule's get argument must be nil"
    end
    -- convert ip string to number
    if type(op_args) == "string" then
        op_args = ip2long(op_args)
    elseif type(op_args) == "table" then
        local new_op_args = {}
        for k, v in pairs(op_args) do
            local new_v = v
            if type(new_v) == "string" then
                new_v = ip2long(new_v)
                if new_v == nil then
                    return string.fromat("%s is not a valid ip address", v)
                end
            end
            new_op_args[k] = new_v
        end
        op_args = new_op_args
    end
    params["op_args"] = op_args

    local err = operator.validate_op_args(op, op_args)
    if err ~= nil then
        return err
    end
end

function _M.process(params)
    local req_info = _M.get()
    local op, op_args = params['op'], params['op_args']
    return operator[op](req_info, op_args)
end

return _M
