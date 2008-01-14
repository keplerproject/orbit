
require "lfs"

module("orbit.cache", package.seeall)

local function pathinfo_to_file(path_info)
  path_info = string.sub(path_info, 2, #path_info)
  path_info = string.gsub(path_info, "/", "-")
  if path_info == "" then path_info = "index" end
  return path_info .. '.html'
end

function get(cache, key)
  local filename = cache.base_path .. "/" .. pathinfo_to_file(key)
  local web = { headers = {} }
  if lfs.attributes(filename, "mode") == "file" then
    return cache.app:serve_static(web, filename), web.headers
  end
end

local function writefile(filename, contents)
  local file = io.open(filename, "wb")
  if file and lfs.lock(file, "w") then
     file:write(contents)
     lfs.unlock(file)
     file:close()
  elseif file then
     file:close()
  end
end

function set(cache, key, value)
  local filename = cache.base_path .. "/" .. pathinfo_to_file(key)
  writefile(filename, value)
end

local function cached(cache, f)
  return function (web, ...)
	    local body, headers = cache:get(web.path_info)
	    if body then
	      for k, v in pairs(headers) do
		web.headers[k] = v
	      end
	      return body
	    else
	      local key = web.path_info
	      local body = f(web, ...)
	      cache:set(key, body)
	      return body
	    end
	 end
end

function invalidate(cache, key)
   local filename = cache.base_path .. "/" .. pathinfo_to_file(key)
   assert(os.remove(filename))
end

function new(app, base_path)
   local dir = lfs.attributes(base_path, "mode")
   if not dir then
      lfs.mkdir(base_path)
   elseif dir ~= "directory" then
      error("base path of cache " .. base_path .. " not a directory")
   end
   local cache = { app = app, 
		   base_path = base_path }
   setmetatable(cache, { __index = _M, __call = function (tab, f)
						   return cached(tab, f)
						end })
   return cache
end
