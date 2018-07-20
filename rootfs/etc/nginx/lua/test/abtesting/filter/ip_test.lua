package.path = "./rootfs/etc/nginx/lua/?.lua;./rootfs/etc/nginx/lua/test/mocks/?.lua;" .. package.path

describe("ABTesting ip module", function()
    before_each(function()
        _G.ngx = { req = { get_headers = function() return {["X-Real-IP"]="127.0.0.1"} end } }
    end)
    -- local abteseting_ip = require("abtesting.filter.ip")

    -- describe("check_rule()", function()
    --     it("bad get args", function()
    --         local rule = {}
    --         local err = abteseting_ip.check_rule(rule)
    --         assert.is_not.equal(err, nil)
    --         rule = {["get_args"]=111 }
    --         err = abteseting_ip.check_rule(rule)
    --         assert.is_nil(err)
    --     end)
    -- end)
    -- describe("get()", function()
    --     it("get ip", function()
    --         local val = abteseting_ip.get()
    --         assert.equal(val, 8388097)
    --     end)
    -- end)
    --describe("process()", function()
    --    it("bad get args", function()
    --        local rule = {
    --            ["get_args"] = "hahaha",
    --            ["op"] = "equal",
    --            ["op_args"] = "abcdefg",
    --        }
    --        local ret = abteseting_ip.process(rule)
    --        assert.equal(ret, true)
    --    end)
    -- end)
end)
