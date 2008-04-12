
local orbit = require "orbit"
local cosmo = require "cosmo"

local io, string = io, string
local setmetatable, loadstring, setfenv = setmetatable, loadstring, setfenv
local type, error, tostring = type, error, tostring
local print, pcall, xpcall, traceback = print, pcall, xpcall, debug.traceback

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
    local template = 
      load_template(env.web.real_path .. "/" .. key .. ".op")
    if not template then return nil end
    return function (arg)
	     arg = arg or {}
	     if arg[1] then arg.it = arg[1] end
	     local subt_env = setmetatable(arg, { __index = env })
	     return template(subt_env)
	   end
  end
  return val
end

local function abort()
  error(abort)
end

local function make_env(web, initial)
  local env = setmetatable(initial or {}, { __index = env_index })
  env._G = env
  env.app = _G
  env.web = web
  env.abort = abort
  function env.lua(arg)
    local f, err = loadstring(arg[1])
    if not f then error(err .. " in \n" .. arg[1]) end
    setfenv(f, env)
    local ok, res = pcall(f)
    if not ok and res ~= abort then 
      error(res .. " in \n" .. arg[1]) 
    elseif ok then
      return res or ""
    else
      abort()
    end
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
    abort()
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
  env.mapper = orbit.model.new()
  function env.model(name, dao)
    if type(name) == "table" then
      name, dao = name[1], name[2]
    end
    return env.mapper:new(name, dao)
  end
  return env
end

function fill(web, filename, env)
  local template = load_template(filename)
  if template then
    local ok, res = xpcall(function () return template(make_env(web, env)) end,
			   function (msg) 
			     if msg == abort then 
			       return msg 
			     else 
			       return traceback(msg) 
			     end
			   end)
    if not ok and res ~= abort then
      error(res)
    elseif ok then
      return res
    else
      return "abort"
    end
  end
end

function handle_get(web)
  local filename = web.path_translated
  web.real_path = splitpath(filename)
  local res = fill(web, filename)
  if res then
    return res
  else
     web.status = 404
     return [[<html>
	      <head><title>Not Found</title></head>
	      <body><p>Not found!</p></body></html>]]
  end
end

handle_post = handle_get

return _M
