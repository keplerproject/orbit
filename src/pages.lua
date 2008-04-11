
local orbit = require "orbit"
local cosmo = require "cosmo"

local io, string = io, string
local setmetatable, loadstring, setfenv = setmetatable, loadstring, setfenv
local type, error, tostring = type, error, tostring
local print = print

local _G = _G

module("orbit.pages", orbit.new)

local template_cache = {}

local function remove_shebang(s)
  return s:gsub("^#![^\n]+", "")
end

local function splitpath(filename)
  local path, file = string.match(filename, "^(.*)[/\\]([^/\\]*)$")
  return path, file
end

local function load_template(filename)
  local template = template_cache[filename]
  if not template then
     local file = io.open(filename)
     if not file then
	return nil
     end
     template = cosmo.compile(remove_shebang(file:read("*a")))
     template_cache[filename] = template
     file:close()
  end
  return template
end

local function env_index(env, key)
  local val = _G[key]
  if not val and type(key) == "string" then
    return function (arg)
	     local template = 
	       load_template(env.web.real_path .. "/" .. key .. ".op")
	     if not template then return "$" .. key end
	     arg = arg or {}
	     if arg[1] then arg.it = arg[1] end
	     local subt_env = setmetatable(arg, { __index = env })
	     return template(subt_env)
	   end
  end
  return val
end

function handle_get(web)
  local env = setmetatable({}, { __index = env_index })
  env.web = web
  local filename = web.path_translated
  web.real_path = splitpath(filename)
  function env.lua(arg)
    local f, err = loadstring(arg[1])
    if not f then error(err .. " in \n" .. arg[1]) end
    setfenv(f, env)
    local res = f()
    return res or ""
  end
  env["if"] = function (arg)
		if arg[1] then
		  cosmo.yield{ it = arg[1], _template = 1 }
		else
		  cosmo.yield{ _template = 2 }
		end
	      end
  function env.redirect(arg)
    web:redirect(arg[1])
    return ""
  end
  function env.fill(arg)
    cosmo.yield(arg[1])
  end
  function env.include(arg)
    local filename
    local name = arg[1]
    if name:sub(1, 1) == "/" then
      filename = web.doc_root .. name
    else
      filename = web.real_path .. "/" .. name
    end
    local template = load_template(filename)
    if not template then return "" end
    local subt_env
    if arg[2] then
      if type(arg[2]) ~= "table" then arg[2] = { it = arg[2] } end
      subt_env = setmetatable(arg[2], { __index = env })
    else
      subt_env = env
    end
    return template(subt_env)
  end
  function env.model(arg)
    return _M:model(arg[1])
  end
  local template = load_template(filename)
  if template then
     return template(env)
  else
     web.status = 404
     return [[<html>
	      <head><title>Not Found</title></head>
	      <body><p>Not found!</p></body></html>]]
  end
end

handle_post = handle_get

return _M
