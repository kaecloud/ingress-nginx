package.path = "./rootfs/etc/nginx/lua/?.lua;./rootfs/etc/nginx/lua/test/mocks/?.lua;" .. package.path
_G._TEST = true

local _ngx = {
    shared = {},
    log = function(...) end,
    say = function(...) end,
}
_G.ngx = _ngx

local abtesting, rules

local function reset_abtesting()
    package.loaded["abtesting"] = nil
    abtesting = require("abtesting")
end

local function reset_rules()
    rules = {
        {
            name = "access-router-production-web-80", port = "80", secure = false,
            secureCACert = { secret = "", caFilename = "", pemSha = "" },
            sslPassthrough = false,
            endpoints = {
                { address = "10.184.7.40", port = "8080", maxFails = 0, failTimeout = 0 },
                { address = "10.184.97.100", port = "8080", maxFails = 0, failTimeout = 0 },
                { address = "10.184.98.239", port = "8080", maxFails = 0, failTimeout = 0 },
            },
            sessionAffinityConfig = { name = "", cookieSessionAffinity = { name = "", hash = "" } },
        },
        { name = "my-dummy-app-1", ["load-balance"] = "round_robin", },
        { name = "my-dummy-app-2", ["load-balance"] = "round_robin", ["upstream-hash-by"] = "$request_uri", },
        {
            name = "my-dummy-app-3", ["load-balance"] = "ewma",
            sessionAffinityConfig = { name = "cookie", cookieSessionAffinity = { name = "route", hash = "sha1" } }
        },
        { name = "my-dummy-app-4", ["load-balance"] = "ewma", },
        {
            name = "my-dummy-app-5", ["load-balance"] = "ewma", ["upstream-hash-by"] = "$request_uri",
            sessionAffinityConfig = { name = "cookie", cookieSessionAffinity = { name = "route", hash = "sha1" } }
        },
    }
end

describe("Balancer", function()
    before_each(function()
        reset_abtesting()
        reset_rules()
    end)

    -- describe("sync_backend()", function()
    --     local backend, implementation

    --     before_each(function()
    --         backend = backends[1]
    --         implementation = expected_implementations[backend.name]
    --     end)

    --     it("initializes balancer for given backend", function()
    --         local s = spy.on(implementation, "new")

    --         assert.has_no.errors(function() balancer.sync_backend(backend) end)
    --         assert.spy(s).was_called_with(implementation, backend)
    --     end)

    --     it("replaces the existing balancer when load balancing config changes for backend", function()
    --         assert.has_no.errors(function() balancer.sync_backend(backend) end)

    --         backend["load-balance"] = "ewma"
    --         local new_implementation = package.loaded["balancer.ewma"]

    --         local s_old = spy.on(implementation, "new")
    --         local s = spy.on(new_implementation, "new")
    --         local s_ngx_log = spy.on(_G.ngx, "log")

    --         assert.has_no.errors(function() balancer.sync_backend(backend) end)
    --         assert.spy(s_ngx_log).was_called_with(ngx.ERR,
    --             "LB algorithm changed from round_robin to ewma, resetting the instance")
    --         -- TODO(elvinefendi) figure out why
    --         -- assert.spy(s).was_called_with(new_implementation, backend) does not work here
    --         assert.spy(s).was_called(1)
    --         assert.spy(s_old).was_not_called()
    --     end)

    --     it("calls sync(backend) on existing balancer instance when load balancing config does not change", function()
    --         local mock_instance = { sync = function(...) end }
    --         setmetatable(mock_instance, implementation)
    --         implementation.new = function(self, backend) return mock_instance end
    --         assert.has_no.errors(function() balancer.sync_backend(backend) end)

    --         stub(mock_instance, "sync")

    --         assert.has_no.errors(function() balancer.sync_backend(backend) end)
    --         assert.stub(mock_instance.sync).was_called_with(mock_instance, backend)
    --     end)
    -- end)
end)
