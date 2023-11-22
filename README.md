# Kong HTTP Log with JSON Body Plugin

The Kong HTTP Log with JSON Body plugin enhances the standard logging capabilities by forwarding request and response bodies, specifically in JSON format, to an upstream log server along with other log entries.

## Installation

This plugin can be installed ~~via luarocks or~~ by cloning the repository and manually configuring it within your Kong setup.

### ~~Via Luarocks~~ (not available yet)

```bash
luarocks install kong-plugin-http-log-with-json-body
```

### Manual Installation

See [(un)Installing your plugin](https://docs.konghq.com/gateway/latest/plugin-development/distribution/)

## Configuration
Plugin Parameters

- **method:** HTTP method used to send logs.
- **timeout:** Timeout for the HTTP log request.
- **keepalive:** Keepalive duration for the connection.
- **content_type:** Content type of the payload.
- **http_endpoint:** URL of the upstream server to which logs will be forwarded.
- **headers:** Additional headers to include in the request.
- **custom_fields_by_lua:** Custom Lua expressions for adding fields to log entries.

### Example Configuration

```yaml
plugins:
  - name: http-log-with-json-body
    config:
      method: POST
      timeout: 5000
      keepalive: 60000
      content_type: application/json
      http_endpoint: https://your-log-server-endpoint.com/logs
      headers:
        X-Api-Version: v1
      custom_fields_by_lua:
        user_id: "ngx.ctx.authenticated_user.id"
        user_role: "ngx.ctx.authenticated_user.role"
```

## Usage

Once the plugin is installed and configured, it will automatically intercept API requests and responses, serializing the JSON bodies of requests and responses, and forward these log entries, along with other configured fields, to the specified HTTP endpoint.
Compatibility

## License

This plugin is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
Issues

If you encounter any issues or have suggestions for improvement, please open an issue on the GitHub repository.