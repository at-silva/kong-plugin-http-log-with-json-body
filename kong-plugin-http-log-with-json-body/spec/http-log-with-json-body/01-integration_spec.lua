local helpers = require "spec.helpers"
local cjson = require "cjson"

local PLUGIN_NAME = "http-log-with-json-body"

local function reset_log(logname)
  local client = assert(helpers.http_client(helpers.mock_upstream_host,
      helpers.mock_upstream_port))
  assert(client:send {
      method  = "DELETE",
      path    = "/reset_log/" .. logname,
      headers = {
        Accept = "application/json"
      }
  })
  client:close()
end

local function get_log(typ, n)
  local entries
  helpers.wait_until(function()
    local client = assert(helpers.http_client(helpers.mock_upstream_host,
                                              helpers.mock_upstream_port))
    local res = client:get("/read_log/" .. typ, {
      headers = {
        Accept = "application/json"
      }
    })
    local raw = assert.res_status(200, res)
    local body = cjson.decode(raw)

    entries = body.entries
    return #entries > 0
  end, 10)
  if n then
    assert(#entries == n, "expected " .. n .. " log entries, but got " .. #entries)
  end
  return entries
end

for _, strategy in helpers.all_strategies() do if strategy ~= "cassandra" then
  describe(PLUGIN_NAME .. ": (access) [#" .. strategy .. "]", function()
    local client

    lazy_setup(function()

      local bp = helpers.get_db_utils(strategy == "off" and "postgres" or strategy, nil, { PLUGIN_NAME })

      local service1 = bp.services:insert{
        protocol = "http",
        host = helpers.mock_upstream_host,
        port = helpers.mock_upstream_port,
      }

      local route1 = bp.routes:insert({
        hosts = { "test1.com" },
        service = service1
      })

      -- add the plugin to test to the route we created
      bp.plugins:insert {
        name = PLUGIN_NAME,
        route = { id = route1.id },
        config = {
          http_endpoint = "http://" .. helpers.mock_upstream_host
          .. ":"
          .. helpers.mock_upstream_port
          .. "/post_log/http_log_with_body",
        },
      }

      -- start kong
      assert(helpers.start_kong({
        -- set the strategy
        database   = strategy,
        -- use the custom test template to create a local mock server
        nginx_conf = "spec/fixtures/custom_nginx.template",
        -- make sure our plugin gets loaded
        plugins = "bundled," .. PLUGIN_NAME,
        -- write & load declarative config, only if 'strategy=off'
        declarative_config = strategy == "off" and helpers.make_yaml_file() or nil,
      }))
    end)

    lazy_teardown(function()
      helpers.stop_kong(nil, true)
    end)

    before_each(function()
      client = helpers.proxy_client()
    end)

    after_each(function()
      if client then client:close() end
    end)

    describe("request", function()
      it("forwards the json body to the upstream service", function()
        reset_log("http_log_with_body")
        local request_body = {["msg"]="hello world"}
        local r = client:post("/status/200", {
          headers = {
            ["Host"] = "test1.com",
            ["Content-Type"] = "application/json",
          },
          body = request_body
        })

        assert.response(r).has.status(200)

        local entries = get_log("http_log_with_body", 1)
        assert.same(request_body, entries[1].request.body)
        assert.is_not_nil(entries[1].response.body)
      end)

      it("does not forward the json body to the upstream service when content-type is not json", function()
        reset_log("http_log_with_body")
        local request_body = "hello world"
        local r = client:post("/status/200", {
          headers = {
            ["Host"] = "test1.com",
            ["Content-Type"] = "text/plain",
          },
          body = request_body
        })

        assert.response(r).has.status(200)

        local entries = get_log("http_log_with_body", 1)
        assert.is_nil(entries[1].request.body)
      end)
    end)

  end)

end end