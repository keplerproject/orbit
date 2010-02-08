
local routes = require "orbit.routes"
local schema = require "orbit.schema"

local plugin = { name = "nodes" }

local R = orbit.routes.R

local methods = {}

function methods:view_home(web)
  local home_id = self.config.home_page or "/index"
  local node = self.models.node:find_by_nice_id{ home_id }
  if node then
    return self:view_node(web, node)
  else
    return self.not_found(web)
  end
end

function methods:view_node(web, node, raw)
  local type = node.type
  local template
  if node.nice_id then
    template = self.theme:load("pages/" .. node.nice_id:sub(2):gsub("/", "-") .. ".html")
  end
  template = template or self.theme:load("pages/" .. type .. ".html")
  if template then
    if raw then
      return template:render(web, { node = node })
    else
      return self:layout(web, template:render(web, { node = node }))
    end
  else
    return self.not_found(web)
  end
end

function methods:view_node_id(web, params)
  local id = tonumber(params.id)
  local node = self.models.node:find(id)
  if node then
    return self:view_node(web, node)
  else
    return self.not_found(web)
  end
end

function methods:view_node_id_raw(web, params)
  local id = tonumber(params.id)
  local node = self.models.node:find(id)
  if node then
    return self:view_node(web, node, true)
  else
    return self.not_found(web)
  end
end

function methods:view_nice(web, params)
  local nice_handle = "/" .. params.splat[1]
  local node = self.models.node:find_by_nice_id{ nice_handle }
  if node then
    return self:view_node(web, node)
  else
    return self.reparse
  end
end

function methods:view_node_type(web, params)
  local type, id = params.type, tonumber(params.id)
  if self.models.types[type] and id then
    local node = self.models.types[type]:find(id)
    if node then
      return self:view_node(web, node)
    end
  end
  return self.reparse
end

function methods:view_node_type_raw(web, params)
  local type, id = params.type, tonumber(params.id)
  if self.models.types[type] and id then
    local node = self.models.types[type]:find(id)
    if node then
      return self:view_node(web, node, true)
    end
  end
  return self.reparse
end

local node_routes = {
    { pattern = R'/', handler = methods.view_home, method = "get" },
    { pattern = R'/node/:id', handler = methods.view_node_id, method = "get" },
    { pattern = R'/node/:id/raw', handler = methods.view_node_id_raw, method = "get" },
    { pattern = R'/:type/:id', handler = methods.view_node_type, method = "get" },
    { pattern = R'/:type/:id/raw', handler = methods.view_node_type_raw, method = "get" },
    { pattern = R'/*', handler = methods.view_nice, method = "get" },
}

local blocks = {}

local show_latest_tmpl = [=[
  <div id = "$id">
    <h2>$title</h2>
    <ul>
    $nodes[[
      <li><a href = "$node_url{ raw }">$title</a></li>
    ]]
    </ul>
  </div>
]=]

local show_latest_body_tmpl = [=[
  <div id = "$id">
    <h2>$title</h2>
    $nodes[[
	<h3><a href = "$node_url{raw}">$title</a></h3>
	$body
    ]]
  </div>
]=]

function blocks.show_latest(app, args, tmpl)
  args = args or {}
  tmpl = tmpl or template.compile(show_latest_tmpl)
  return function (web, env, name)
	   local fields = { "id", "nice_id", "title", unpack(args.includes or {}) }
	   local nodes = app.models[args.node or "node"]:find_latest{ count = args.count,
								     fields = fields }
	   return tmpl:render(web, { title = args.title, nodes = nodes, id = args.id or name })
	 end
end

function blocks.show_latest_body(app, args, tmpl)
  args = args or {}
  tmpl = tmpl or template.compile(show_latest_body_tmpl)
  return function (web, env, name)
	   local fields = { "id", "nice_id", "title", "body", unpack(args.includes or {}) }
	   local nodes = app.models[args.node or "node"]:find_latest{ count = args.count,
								     fields = fields }
	   return tmpl:render(web, { title = args.title, nodes = nodes, id = args.id or name })
	 end
end

local node_info_tmpl = [=[
    <div id = "$id">
      <h2>$(node.title)</h2>
      $(node.body)
    </div>
]=]

function blocks.node_info(app, args, tmpl)
  args = args or {}
  tmpl = tmpl or template.compile(node_info_tmpl)
  return function (web, env, name)
	   return tmpl:render(web, { node = env.node, id = args.id or name })
	 end
end


function plugin.new(app)
  schema.loadstring([[
    node = entity {
      fields = {
        id = key(),
        type = text(),
        nice_id = text(),
        title = text(),
        body = long_text(),
        created_at = timestamp(),
	terms = has_and_belongs{ "term" }
      }
    }
    page = entity {
      parent = "node", fields = {}	
    }
    post = entity {
      parent = "node",
      fields = {
        byline = text(),
        full_body = long_text()	
      }	
    }
    vocabulary = entity {
      fields = {
	id = key(),
	name = text(),
	display_name = text(),
	terms = has_many{ "term" }
      }
    }
    term = entity {
      fields = {
	id = key(),
	vocabulary = belongs_to{ "vocabulary" },
	parent = has_one{ "term" },
	name = text(),
	display_name = text(),
	nodes = has_and_belongs{ "node", order_by = "weight desc" }
      }
    }
    node_term = entity{
      fields = {
        id = key(),
        node = belongs_to{ "node" },
        term = belongs_to{ "term" },
        weight = integer()
      }
    }
  ]], "@node.lua", app.mapper.schema)
  for k, v in pairs(methods) do
    app[k] = v
  end
  app.models.node = app:model("node")

  function app.models.node:find_latest(args)
    args = args or {}
    count = args.count or 10
    local in_home = { "home", "visibility", entity = "node_term", fields = { "id" },
	              condition = [[node_term.term = term.id and term.vocabulary = vocabulary.id and
	                            term.name = ? and vocabulary.name = ?]], from = { "term", "vocabulary" } }
    return self:find_all("id in ?", { in_home, order = "created_at desc", count = count })
  end
  
  app.models.post = app:model("post")

  function app.models.post:find_latest(args)
    args = args or {}
    count = args.count or 10
    return self:find_all("type = ?", { "post", order = "created_at desc", count = count })
  end

  app.models.page = app:model("page")

  app.models.term = app:model("term")
  app.models.vocabulary = app:model("vocabulary")
  app.models.node_term = app:model("node_term")

  app.models.types.post = app.models.post
  app.models.types.page = app.models.page

  for name, block in pairs(blocks) do
    app.blocks.protos[name] = block
  end

  for _, route in ipairs(node_routes) do
    app.routes[#app.routes+1] = route
  end
end

return plugin
