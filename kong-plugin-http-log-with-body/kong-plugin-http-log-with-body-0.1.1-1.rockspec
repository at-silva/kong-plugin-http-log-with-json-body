package = "kong-plugin-http-log-with-body"
version = "0.0.1-1"
source = {
  url = "git://github.com/at-silva/kong-plugin-http-log-with-body",
  branch = "main"
}
description = {
  summary = "Customized http-log Kong plugin that also logs the request and response body"
}
build = {
  type = "builtin",
  modules = {
    ["kong.plugins.http-log-with-body.handler"] = "kong/plugins/http-log-with-body/handler.lua",
    ["kong.plugins.http-log-with-body.schema"]  = "kong/plugins/http-log-with-body/schema.lua",
  }
}