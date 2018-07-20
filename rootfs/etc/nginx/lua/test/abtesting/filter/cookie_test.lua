package.path = "./rootfs/etc/nginx/lua/?.lua;./rootfs/etc/nginx/lua/test/mocks/?.lua;" .. package.path

describe("ABTesting cookie", function()
    before_each(function()
        _G.ngx = { var = { cookie_hahaha = "abcdefg" } }
    end)
    local abteseting_cookie = require("abtesting.filter.cookie")

    describe("check_rule()", function()
        it("bad get args", function()
            local rule = {}
            local err = abteseting_cookie.check_rule(rule)
            assert.is_not.equal(err, nil)
            rule = {["get_args"]=111 }
            err = abteseting_cookie.check_rule(rule)
            assert.is_not.equal(err, nil)
        end)
        it("good get args", function()
            local rule = {
                ["get_args"] = "hahaha",
                ["op"] = "equal",
                ["op_args"] = "abcdefg",
            }
            local err = abteseting_cookie.check_rule(rule)
            assert.is_nil(err)
        end)
    end)
    describe("get()", function()
        it("get cookie", function()
            local val = abteseting_cookie.get("hahaha")
            assert.equal(val, "abcdefg")
        end)
    end)
    describe("process()", function()
        it("bad get args", function()
            local rule = {
                ["get_args"] = "hahaha",
                ["op"] = "equal",
                ["op_args"] = "abcdefg",
            }
            local ret = abteseting_cookie.process(rule)
            assert.equal(ret, true)
        end)
    end)
end)
