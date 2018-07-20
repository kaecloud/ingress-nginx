package.path = "./rootfs/etc/nginx/lua/?.lua;./rootfs/etc/nginx/lua/test/mocks/?.lua;" .. package.path

describe("ABTesting query", function()
    before_each(function()
        _G.ngx = { req = { get_uri_args = function() return {hahaha="abcdefg"} end } }
    end)

    local abteseting_query = require("abtesting.filter.query")

    describe("check_rule()", function()
        it("bad get args", function()
            local rule = {}
            local err = abteseting_query.check_rule(rule)
            assert.is_not.equal(err, nil)
            rule = {["get_args"]=111 }
            err = abteseting_query.check_rule(rule)
            assert.is_not.equal(err, nil)
        end)
        it("good get args", function()
            local rule = {
                ["get_args"] = "hahaha",
                ["op"] = "equal",
                ["op_args"] = "abcdefg",
            }
            local err = abteseting_query.check_rule(rule)
            assert.is_nil(err)
        end)
    end)
    describe("get()", function()
        it("get query argument", function()
            local val = abteseting_query.get("hahaha")
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
            local ret = abteseting_query.process(rule)
            assert.equal(ret, true)
        end)
    end)
end)
