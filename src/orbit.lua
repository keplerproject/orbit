require "wsapi.request"
require "wsapi.response"
require "wsapi.util"
require "orbit.model"

module("orbit", package.seeall)

apps = {}

app_module_methods = {}

app_instance_methods = {}

function make_tag(name, data, class)
  if class then class = ' class="' .. class .. '"' else class = "" end
  if not data then
    return "<" .. name .. class .. "/>"
  elseif type(data) == "string" then
    return "<" .. name .. class .. ">" .. data ..
      "</" .. name .. ">"
  else
    local attrs = {}
    for k, v in pairs(data) do
      if type(k) == "string" then
	table.insert(attrs, k .. '="' .. tostring(v) .. '"')
      end
    end
    local open_tag = "<" .. name .. class .. " " ..
      table.concat(attrs, " ") .. ">"
    local close_tag = "</" .. name .. ">"
    return open_tag .. table.concat(data) .. close_tag	     
  end	   
end

function app(app_module)
  apps[app_module._NAME] = app_module
  for k, v in pairs(app_module_methods) do
    app_module[k] = v
  end
  app_module.run = function (wsapi_env) 
		     return app_module_methods.run(app_module, wsapi_env)
		   end
  app_module.mapper = orbit.model.new(app_module._NAME .. "_")
  app_module.controllers = {}
  app_module.views = {}
  app_module.models = {}
  app_module.not_found = {
      get = function (self)
	      self.status = "404 Not Found"
	      self.response = [[<html>
		  <head><title>Not Found</title></head>
		  <body><p>Not found!</p></body></html>]]
	    end  
  }
  app_module.server_error = {
      get = function (self, msg)
	      self.status = "500 Server Error"
	      self.response = [[<html>
		  <head><title>Server Error</title></head>
		  <body><p>]] .. msg .. [[</p></body></html>]]
	    end  
  }
  app_module.methods = app_instance_methods
end

function app_module_methods.new(app_module)
  local app_object = { status = "200 Ok", response = "",
    headers = { ["Content-Type"]= "text/html" },
    cookies = {} }
  app_object.controllers = app_module.controllers
  app_object.views = app_module.views
  app_object.models = app_module.models
  app_object.not_found = app_module.not_found
  app_object.server_error = app_module.server_error
  app_object.prefix = app_module.prefix 
  app_object.run = function (wsapi_env) 
		     return app_instance_methods.run(app_object, wsapi_env)
		   end
  setmetatable(app_object, { __index = app_instance_methods })
  return app_object
end

function app_module_methods.add_controllers(app_module, cs)
  for k, v in pairs(cs) do
    app_module.controllers[k] = v
  end
end

function app_module_methods.add_views(app_module, vs)
  for k, v in pairs(vs) do
    local env = { view = function ()
		           local res = coroutine.yield()
			   if type(res) == "table" then
			     res = table.concat(res)
			   end
			   return res
                         end }
    local old_env = getfenv(v)
    setmetatable(env, { __index = function (env, name)
      if old_env[name] then
	return old_env[name]
      else
	local tag = {}
	setmetatable(tag, {
		       __call = function (_, data)
       	                          return make_tag(name, data)
				end,
		       __index = function(_, class)
				   return function (data)
					    return make_tag(name, data, class)
					  end
				 end
		     })
	rawset(env, name, tag)
	return tag
      end
    end })
    setfenv(v, env)
    app_module.views[k] = v
  end
end

function app_module_methods.add_models(app_module, ms)
  for k, v in pairs(ms) do
    app_module.models[k] = app_module.mapper:new(k, v)
  end
  app_module.mapper.models = app_module.models
end

function app_instance_methods.render(app_object, page, args, layout)
  layout = layout or "layout"
  if app_object.views[layout] then
    local co = coroutine.create(app_object.views[layout])
    local ok, res = coroutine.resume(co, app_object, args)
    if not res then
      ok, res = coroutine.resume(co, app_object.views[page](app_object, args))
    end
    app_object.response = res
  else
    app_object.response = app_object.views[page](app_object, args)
  end
end

function app_instance_methods.render_partial(app_object, page, args)
  local res = app_object.views[page](app_object, args)
  if type(res) == "table" then res = table.concat(res) end
  return res
end

function app_instance_methods.redirect(app_object, url)
  app_object.status = "302 Found"
  app_object.headers["Location"] = url
  app_object.response = "redirect"
end

function app_instance_methods.link(app_object, url, params)
  local link = {}
  local prefix = app_object.prefix or ""
  for k, v in pairs(params or {}) do
    link[#link + 1] = k .. "=" .. wsapi.util.url_encode(v)
  end
  local qs = table.concat(link, "&")
  if qs and qs ~= "" then
    return prefix .. url .. "?" .. qs
  else
    return prefix .. url
  end
end

function app_instance_methods.empty(app_object, s)
  return not s or string.match(s, "^%s*$")
end

function app_instance_methods.empty_param(app_object, param)
  return app_object:empty(app_object.input[param])
end

function app_module_methods.run(app_module, wsapi_env)
  local app_object = app_module:new()
  return app_object.run(wsapi_env)
end

function app_instance_methods.dispatch(app_object, path, method)
  for name, con in pairs(app_object.controllers) do
    if not con[1] then
      if path == "/" .. name then
	con[method](app_object)
	return true
      end
    else
      for _, pattern in ipairs(con) do
	local captures = { string.match(path, "^" .. pattern .. "$") }
	if #captures > 0 then
	  con[method](app_object, unpack(captures))
	  return true
	end
      end
    end			      
  end
  return false
end

function app_instance_methods.run(app_object, wsapi_env)
  local req = wsapi.request.new(wsapi_env)
  local res = wsapi.response.new(app_object.status, app_object.headers)
  app_object.set_cookie = function (_, name, value)
			    res:set_cookie(name, value)
			  end
  app_object.delete_cookie = function (_, name)
			       res:delete_cookie(name)
			     end
  app_object.input, app_object.cookies = req.params, req.cookies
  local ok, found = xpcall(function () return app_object:dispatch(req.path_info,
    string.lower(req.method)) end, debug.traceback)
  if not ok then
    app_object.server_error.get(app_object, found)
  elseif not found then
    app_object.not_found.get(app_object)
  end
  res.status = app_object.status
  res:write(app_object.response)
  return res:finish()
end


