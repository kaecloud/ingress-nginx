package.path = "./rootfs/etc/nginx/lua/?.lua;./rootfs/etc/nginx/lua/test/mocks/?.lua;" .. package.path

describe("ABTesting query", function()
    before_each(function()
        _G.ngx = { req = { get_uri_args = function() return {hahaha="abcdefg"} end } }
    end)

    local abteseting_operator = require("abtesting.lib.operator")

    describe("validate_op_args()", function()
        it("equal args", function()
            local err
            err = abteseting_operator.validate_op_args("equal", {})
            assert.is_not.is_nil(err)
            err = abteseting_operator.validate_op_args("equal", 1)
            assert.is_nil(err)
            err = abteseting_operator.validate_op_args("equal", "hahaha")
            assert.is_nil(err)
        end)
        it("range args", function()
            local err
            err = abteseting_operator.validate_op_args("range", "hahah")
            assert.is_not.is_nil(err)
            err = abteseting_operator.validate_op_args("range", {})
            assert.is_not.is_nil(err)
            err = abteseting_operator.validate_op_args("range", {["start"]=5, ["end"]=5})
            assert.is_not.is_nil(err)
            err = abteseting_operator.validate_op_args("range", {["start"]=1, ["end"]=5})
            assert.is_nil(err)
        end)
    end)
    describe("equal op", function()
        it("equal", function()
            local ret, err
            ret, err = abteseting_operator.equal("aaa", "aaa")
            assert.equal(ret, true)
            assert.is_nil(err)
            ret, err = abteseting_operator.not_equal("aaa", "aaa")
            assert.equal(ret, false)
            assert.is_nil(err)
        end)
    end)

    -- describe("regex op", function()
    --     it("regex", function()
    --         local ret, err
    --         ret, err = abteseting_operator.regex("httpieas", "httpie(\\S+)$")
    --         assert.equal(ret, true)
    --         assert.is_nil(err)
    --         ret, err = abteseting_operator.not_regex("aaa", "aaa")
    --         assert.equal(ret, false)
    --         assert.is_nil(err)
    --     end)
    -- end)

    describe("oneof op", function()
        it("oneof", function()
            local ret, err
            ret, err = abteseting_operator.oneof("aaa", {"aaa", "bbb"})
            assert.equal(ret, true)
            assert.is_nil(err)

            ret, err = abteseting_operator.not_oneof("aaa", {"aaa", "bbb"})
            assert.equal(ret, false)
            assert.is_nil(err)

            ret, err = abteseting_operator.oneof("aaa", {"bbb"})
            assert.equal(ret, false)
            assert.is_nil(err)
        end)
    end)

    describe("range op", function()
        it("range", function()
            local ret, err
            ret, err = abteseting_operator.range(1, {["start"]=1, ["end"]=5})
            assert.equal(ret, true)
            assert.is_nil(err)

            ret, err = abteseting_operator.not_range(1, {["start"]=1, ["end"]=5})
            assert.equal(ret, false)
            assert.is_nil(err)

            ret, err = abteseting_operator.range(5, {["start"]=1, ["end"]=5})
            assert.equal(ret, false)
            assert.is_nil(err)
        end)
    end)
end)
