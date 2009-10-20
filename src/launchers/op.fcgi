#!/usr/bin/lua

-- Orbit pages launcher, extracts script to launch

pcall(require, "luarocks.require")

local common = require "wsapi.common"
local fastcgi, err = pcall(require, "wsapi.fastcgi")

if not fastcgi then
  io.stderr:write("WSAPI FastCGI not loaded:\n" .. err .. "\n\nPlease install wsapi-fcgi with LuaRocks\n")
  os.exit(1)
end

local function op_loader(wsapi_env)
  common.normalize_paths(wsapi_env, nil, "op.fcgi")
  local app = wsapi.common.load_isolated_launcher(wsapi_env.PATH_TRANSLATED, "orbit.pages")
  return app(wsapi_env)
end 

fastcgi.run(op_loader)
