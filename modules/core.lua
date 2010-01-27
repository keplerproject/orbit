
local routes = require "orbit.routes"

local core = {}

local R = orbit.routes.R

function core.layout(web, inner_html)
  local layout_template = publique.theme:load("layout.html")
  if layout_template then
    return layout_template:render(web, { inner = inner_html })
  else
    return inner_html
  end
end

function core.home(web)
  local home_template = publique.theme:load("home.html")
  if home_template then
    return core.layout(web, home_template:render(web))
  else
    return publique.not_found(web)
  end
end

publique:dispatch_get(core.home, R'/', R'/home')

return core
