
local template = {}

local cosmo = require "cosmo"
local util = require "modules.util"

local methods = {}
methods.__index = methods

function methods:render(web, env)
  env = setmetatable({ 
		       ["if"] = cosmo.cif,
		       node_url = function (args)
				    local node = args[1]
				    return web:link(node.nice_id or string.format("/%s/%i", node.type, node.id))
				  end
		     }, { __index = env})
  return self.template(env)
end

function template.load(filename)
  local tmpl, err = util.readfile(filename)
  if not tmpl then
    return nil, err
  end
  return template.compile(tmpl, filename)
end

function template.compile(str, filename)
  return setmetatable({ template = cosmo.compile(str, filename) }, methods)
end

return template
