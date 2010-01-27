
local blocks = {}

local template = require "modules.template"

local title_tmpl = [[<title>$title</title>]]

function blocks.title(args, tmpl)
  tmpl = template.compile(tmpl or title_tmpl)
  return function (web)
	   return tmpl:render(web, { title = args[1] })
	 end
end

local js_tmpl = [=[
$js[[
  <script type = "text/javascript" src = "$it"></script>
]]
]=]

function blocks.javascript(args, tmpl)
  tmpl = template.compile(tmpl or js_tmpl)
  return function (web)
	   return tmpl:render(web, { js = args or {} })
	 end
end

local css_tmpl = [=[
$css[[
  <link rel = "stylesheet" type = "text/css" href = "$it"/>
]]
]=]

function blocks.css(args, tmpl)
  tmpl = template.compile(tmpl or css_tmpl)
  return function (web)
	   return tmpl:render(web, { css = args or {} })
	 end
end

local banner_tmpl = [[
  <h1>$title</h1>
  <h3>$tagline</h3>
]]

function blocks.banner(args, tmpl)
  tmpl = template.compile(tmpl or banner_tmpl)
  return function (web)
	   return tmpl:render(web, args)
	 end
end

local copyright_tmpl = [[Copyright $year]]

function blocks.copyright(args, tmpl)
  tmpl = template.compile(tmpl or copyright_tmpl)
  return function (web)
	   return tmpl:render(web, { year = args[1] })
	 end
end

local about_tmpl = [[
  <h3>$title</h3>
  <p>$text</p>
]]

function blocks.about(args, tmpl)
  tmpl = template.compile(tmpl or about_tmpl)
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

function blocks.links(args, tmpl)
  tmpl = template.compile(tmpl or links_tmpl)
  return function (web)
	   return tmpl:render(web, args)
	 end
end

local latest_posts_tmpl = [=[
  <h2>$title</h2>
  <ul>
  $posts[[
    <li><a href = "$node_url{ raw }">$title</a></li>
  ]]
  </ul>
]=]

function blocks.latest_posts(args, tmpl)
  tmpl = template.compile(tmpl or latest_posts_tmpl)
  return function (web)
	   local posts = publique.post:find_latest{ count = args.count,
						    fields = { "id", "nice_id", "title" } }
	   return tmpl:render(web, { title = args.title, posts = posts })
	 end
end

return blocks
