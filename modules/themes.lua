
local themes = {}

local template = require "modules.template"
local util = require "modules.util"

local methods = {}
methods.__index = methods

local template_methods = {}
template_methods.__index = template_methods

function template_methods:render(web, env)
  local blocks = self.theme.app.blocks.instances
  local areas = setmetatable({}, { __index = function (t, name)
					       local area = function (args, has_block)
							      local out = {}
							      args = args or {}
							      for _, block in ipairs(self.theme.areas[name]) do
								out[#out+1] = blocks[block](web, args[block], env)
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
  local tmpl, err = template.load(self.path ..  "/" .. filename)
  if tmpl then
    return setmetatable({ theme = self, tmpl = tmpl }, template_methods)
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
    return setmetatable(theme, methods)
  else
    return nil, err
  end
end

return themes
