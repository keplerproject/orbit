#!/usr/bin/lua

-- Orbit pages launcher, extracts script to launch
-- from SCRIPT_FILENAME/PATH_TRANSLATED

pcall(require, "luarocks.require")

local common = require "wsapi.common"
local cgi = require "wsapi.cgi"
local op = require "orbit.pages"

local arg_filename = (...)

local function op_loader(wsapi_env)
  common.normalize_paths(wsapi_env, arg_filename, "op.cgi")
  return op.run(wsapi_env)
end 

cgi.run(op_loader)
