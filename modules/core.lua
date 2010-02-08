
local orbit = require "orbit"
local model = require "orbit.model"
local routes = require "orbit.routes"
local util = require "modules.util"
local blocks = require "modules.blocks"
local themes = require "modules.themes"
local lfs = require "lfs"

local core = {}

local R = orbit.routes.R

local methods = {}

function methods:layout(web, inner_html)
  local layout_template = self.theme:load("layout.html")
  if layout_template then
    return layout_template:render(web, { inner = inner_html })
  else
    return inner_html
  end
end

function core.load_plugins(app)
  for _, file in ipairs(app.config.plugins or {}) do
    local plugin = dofile(app.real_path .. "/plugins/" .. file)
    app.plugins[plugin.name] = plugin.new(app)
  end
end

function methods:block_template(block)
  local tmpl, err = self.theme:load("blocks/" .. block .. ".html")
  return tmpl
end

function core.new(app)
  app = orbit.new(app)
  for k, v in pairs(methods) do
    app[k] = v
  end
  app.blocks = { protos = blocks, instances = {} }
  app.config = util.loadin(app.real_path .. "/config.lua")
  if not app.config then
    error("cannot find config.lua in " .. app.real_path)
  end
  app.theme = themes.new(app.blocks.instances, app.config.theme, app.real_path .. "/themes")
  if not app.theme then
    error("theme " .. app.config.theme .. " not found")
  end
  app.models = { types = {} }
  app.plugins = {}
  app.routes = {}
  local luasql = require("luasql." .. app.config.database.driver)
  local env = luasql[app.config.database.driver]()
  app.mapper.logging = true
  app.mapper.conn = env:connect(unpack(app.config.database.connection))
  app.mapper.driver = model.drivers[app.config.database.driver]
  app.mapper.schema = { entities = {} }
  core.load_plugins(app)
  for name, proto in pairs(app.config.blocks) do
    app.blocks.instances[name] = app.blocks.protos[proto[1]](app, proto.args, app:block_template(name))
  end
  for _, route in ipairs(app.routes) do
    app["dispatch_" .. route.method](app, function (...) return route.handler(app, ...) end, route.pattern)
  end
end

return core
