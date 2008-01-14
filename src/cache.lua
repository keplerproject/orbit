
require "lfs"

module("orbit.cache", package.seeall)

local function readfile(filename)
  local file = io.open(filename, "rb")
  if file then
    repeat until lfs.lock(file, "r")
    local contents = file:read("*a")
    lfs.unlock(file)
    file:close()
    return contents
  end
end

local function pathinfo_to_file(path_info)
  path_info = string.sub(path_info, 2, #path_info)
  path_info = string.gsub(path_info, "/", "-")
  if path_info == "" then path_info = "index" end
  return path_info .. '.html'
end

local function parse_headers(s)
  local headers = {}
  for header in string.gmatch(s, "[^\r\n]+") do
    local name, value = string.match(header, "^([^:]+):%s+(.+)$")
    if headers[name] then
      if type(headers[name]) == "table" then
        table.insert(headers[name], value)
      else
        headers[name] = { headers[name], value }
      end
    else
      headers[name] = value
    end
  end
  return headers
end

local function parse_response(contents)
  local b, e = string.find(contents, "\r\n\r\n")
  local headers = string.sub(contents, 1, b + 1)
  local body = string.sub(contents, e + 1, #contents)
  return body, parse_headers(headers)
end

function get(cache, key)
  local filename = cache.base_path .. "/" .. pathinfo_to_file(key)
  local contents = readfile(filename)
  if contents then
     if cache.cache_headers then
	return parse_response(contents)
     else
	return contents
     end
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

local function joinheaders(headers)
  local hs = {}
  for k, v in pairs(headers) do
    if type(v) == "table" then
      for _, tv in ipairs(v) do
        table.insert(hs, string.format("%s: %s", k, v))
      end
    else
      table.insert(hs, string.format("%s: %s", k, v))
    end
  end
  return table.concat(hs, "\r\n")
end

function set(cache, key, value)
  local filename = cache.base_path .. "/" .. pathinfo_to_file(key)
  local contents
  if cache.cache_headers then
     contents = joinheaders(value.headers) .. "\r\n\r\n" .. value.body
  else
     contents = value
  end
  writefile(filename, contents)
end

local function cached(cache, f)
  return function (web, ...)
	    local body, headers = cache:get(web.path_info)
	    if body then
	       if headers then
		  for k, v in headers do
		     web.headers[k] = v
		  end
	       end
	       return body
	    else
	       local key = web.path_info
	       local body = f(web, ...)
	       if cache.cache_headers then
		  cache:set(key, { headers = web.headers, body = body })
	       else
		  cache:set(key, body)
	       end
	       return body
	    end
	 end
end

function invalidate(cache, key)
   local filename = cache.base_path .. "/" .. pathinfo_to_file(key)
   assert(os.remove(filename))
end

function new(base_path, cache_headers)
   local dir = lfs.attributes(base_path, "mode")
   if not dir then
      lfs.mkdir(base_path)
   elseif dir ~= "directory" then
      error("base path of cache " .. base_path .. " not a directory")
   end
   local cache = { base_path = base_path, cache_headers = cache_headers }
   setmetatable(cache, { __index = _M, __call = function (tab, f)
						   return cached(tab, f)
						end })
   return cache
end
