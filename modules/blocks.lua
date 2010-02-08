
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

return blocks
