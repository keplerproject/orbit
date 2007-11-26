require"orbit"

local env = { PATH_INFO = select(1, ...) or "/say/fabio",
              REQUEST_METHOD = select(2, ...) or "get" }

SAPI = {}
SAPI.Request = {}
SAPI.Response = {}
SAPI.Request.servervariable = function (name)
  return env[name]
end
SAPI.Response.header = function (k, v) print(k .. ": " .. v) end
SAPI.Response.write = function (data) print(data) end
orbit.serve("samples/hello.lua")
