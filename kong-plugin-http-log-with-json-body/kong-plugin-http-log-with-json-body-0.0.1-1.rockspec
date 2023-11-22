package = "kong-plugin-http-log-with-json-body"
version = "0.0.1-1"
source = {
  url = "git://github.com/at-silva/kong-plugin-http-log-with-json-body",
  branch = "main"
}
description = {
  summary = "Customized http-log Kong plugin that also logs the request and response body"
}
build = {
  type = "builtin",
  modules = {
    ["kong.plugins.http-log-with-json-body.handler"] = "kong/plugins/http-log-with-json-body/handler.lua",
    ["kong.plugins.http-log-with-json-body.schema"]  = "kong/plugins/http-log-with-json-body/schema.lua",
  }
}