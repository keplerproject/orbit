
local themes = {}

local template = require "modules.template"
local util = require "modules.util"
local lfs = require "lfs"

local methods = {}
methods.__index = methods

local template_methods = {}
template_methods.__index = template_methods

function template_methods:render(web, env)
  local blocks = self.theme.app.blocks.instances
  local areas = setmetatable({}, { __index = function (t, name)
					       local area = function (args, has_block)
							      local out = {}
							      for _, block in ipairs(self.theme.areas[name]) do
								out[#out+1] = blocks[block](web, env, block)
							      end
							      return table.concat(out)
							    end
					       t[name] = area
					       return area
					     end })
  local env = setmetatable({ areas = areas }, { __index = env })
  return self.tmpl:render(web, env)
end

function methods:block_template(block)
  local tmpl, err = self:load("blocks/" .. block .. ".html")
  return tmpl
end

function methods:load(filename)
  local cached = self.cache[filename]
  local timestamp = lfs.attributes(self.path .. "/" .. filename, "modification")
  if cached and cached.when == timestamp then
    return cached.template
  end
  local tmpl, err = template.load(self.path ..  "/" .. filename)
  if tmpl then
    local template = setmetatable({ theme = self, tmpl = tmpl }, template_methods)
    self.cache[filename] = { template = template, when = modif }
    return template
  else
    return tmpl, err
  end
end

function themes.new(app, name, path)
  local theme_path = path .. "/" .. name
  local theme, err = util.loadin(theme_path .. "/config.lua")
  if theme then
    theme.app = app
    theme.name = name
    theme.path = theme_path
    theme.cache = setmetatable({}, { __mode = "v" })
    return setmetatable(theme, methods)
  else
    return nil, err
  end
end

return themes
