
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
  <h1>$title</h1>
  <h3>$tagline</h3>
]]

function blocks.banner(app, args, tmpl)
  tmpl = tmpl or template.compile(banner_tmpl)
  return function (web)
	   return tmpl:render(web, args)
	 end
end

local copyright_tmpl = [[Copyright $year]]

function blocks.copyright(app, args, tmpl)
  tmpl = tmpl or template.compile(copyright_tmpl)
  return function (web)
	   return tmpl:render(web, { year = args[1] })
	 end
end

local about_tmpl = [[
  <h3>$title</h3>
  <p>$text</p>
]]

function blocks.about(app, args, tmpl)
  tmpl = tmpl or template.compile(about_tmpl)
  return function (web)
	   return tmpl:render(web, args)
	 end
end

local links_tmpl = [=[
  <h3>$title</h3>
  <ul>
    $links[[<li><a href = "$2">$1</a></li>]]
  </ul>
]=]

function blocks.links(app, args, tmpl)
  tmpl = tmpl or template.compile(links_tmpl)
  return function (web)
	   return tmpl:render(web, args)
	 end
end

local show_latest_tmpl = [=[
  <h2>$title</h2>
  <ul>
  $nodes[[
    <li><a href = "$node_url{ raw }">$title</a></li>
  ]]
  </ul>
]=]

function blocks.show_latest(app, args, tmpl)
  tmpl = tmpl or template.compile(show_latest_tmpl)
  return function (web)
	   local nodes = app.nodes[args.node or "post"]:find_latest{ count = args.count,
							   fields = { "id", "nice_id", "title" } }
	   return tmpl:render(web, { title = args.title, nodes = nodes })
	 end
end

return blocks
