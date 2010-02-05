
local blocks = {}

local template = require "modules.template"

local title_tmpl = [[<title>$title</title>]]

function blocks.title(app, args, tmpl)
  tmpl = tmpl or template.compile(title_tmpl)
  return function (web)
	   return tmpl:render(web, { title = args[1] })
	 end
end

local js_tmpl = [=[
$js[[
  <script type = "text/javascript" src = "$it"></script>
]]
]=]

function blocks.javascript(app, args, tmpl)
  tmpl = tmpl or template.compile(js_tmpl)
  return function (web)
	   return tmpl:render(web, { js = args or {} })
	 end
end

local css_tmpl = [=[
$css[[
  <link rel = "stylesheet" type = "text/css" href = "$it"/>
]]
]=]

function blocks.css(app, args, tmpl)
  tmpl = tmpl or template.compile(css_tmpl)
  return function (web)
	   return tmpl:render(web, { css = args or {} })
	 end
end

local banner_tmpl = [[
  <div id = "$id">
    <h1><a href = "$(web:link('/'))">$title</a></h1>
    <h3>$tagline</h3>
  </div>
]]

function blocks.banner(app, args, tmpl)
  args = args or {}
  tmpl = tmpl or template.compile(banner_tmpl)
  return function (web, env, name)
	   args.id = args.id or name
	   return tmpl:render(web, args)
	 end
end

local copyright_tmpl = [[
  <div id = "$id">
    <p>Copyright $year</p>
  </div>
]]

function blocks.copyright(app, args, tmpl)
  args = args or {}
  tmpl = tmpl or template.compile(copyright_tmpl)
  return function (web, env, name)
	   return tmpl:render(web, { year = args[1], id = args.id or name })
	 end
end

local generic_tmpl = [[
  <div id = "$id">
    <h3>$title</h3>
    <p>$text</p>
  </div>
]]

function blocks.generic(app, args, tmpl)
  args = args or {}
  tmpl = tmpl or template.compile(generic_tmpl)
  return function (web, env, name)
	   args.id = args.id or name
	   return tmpl:render(web, args)
	 end
end

local links_tmpl = [=[
  <div id = "$id">
    <h3>$title</h3>
    <ul>
      $links[[<li><a href = "$2">$1</a></li>]]
    </ul>
  </div>
]=]

function blocks.links(app, args, tmpl)
  args = args or {}
  tmpl = tmpl or template.compile(links_tmpl)
  return function (web, env, name)
	   args.id = args.id or name
	   return tmpl:render(web, args)
	 end
end

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
	   local nodes = app.nodes[args.node or "all"]:find_latest{ count = args.count,
								     fields = fields }
	   return tmpl:render(web, { title = args.title, nodes = nodes, id = args.id or name })
	 end
end

function blocks.show_latest_body(app, args, tmpl)
  args = args or {}
  tmpl = tmpl or template.compile(show_latest_body_tmpl)
  return function (web, env, name)
	   local fields = { "id", "nice_id", "title", "body", unpack(args.includes or {}) }
	   local nodes = app.nodes[args.node or "all"]:find_latest{ count = args.count,
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

return blocks
