
local template = require "modules.template"
local forms = require "modules.form"
local route = require "orbit.routes"
local json = require "json"
local schema = require "orbit.schema"

local R = route.R
local plugin = { name = "mock_poll" }

local poll_form = [=[
  $form{ id = form_id, url = url, obj = {} }[[
    $radio{ field = "option", wrap_ul = wrap_ul, ul_class = ul_class, li_class = li_class, list = options }
    $button{ id = "vote", label = "Vote", action = "post_redirect_inline", to = result,
              container = div_id }
  ]]
]=]

local poll_tmpl = [=[
  <div id = "$div_id">
    <h2>$title</h2>
    $body
    $form
  </div>
]=]

local function block_poll(app, args, tmpl)
  args = args or {}
  tmpl = tmpl or template.compile(poll_tmpl)
  local form_tmpl = cosmo.compile(poll_form)
  return function (web, env, name)
       local div_id = args.id or name
	   local poll = app.nodes.poll:find_latest()
	   local options = {}
	   for _, option in ipairs(poll.options) do
		 options[#options+1] = { value = option.id, text = option.name }
	   end
	   local form = function (args)
	     args = args or {}
		 return form_tmpl{ form = forms.form, form_id = "form_" .. div_id, div_id = div_id,
			       wrap_ul = args.wrap_ul, result = web:link("/poll/" .. poll.id .. "/raw"),
			       url = web:link("/poll/" .. poll.id .. "/vote"), options = options,
			 	   ul_class = args.ul_class, li_class = args.li_class }
	   end	
	   local env = setmetatable({ div_id = args.id or name, form = form }, { __index = poll })
	   return tmpl:render(web, env)
	 end
end

local poll_total_tmpl = [=[
  <h2>$title</h2>
  $body
  <ul>
      $options[[
      <li>$name: $votes ($format{ "%.1f", (votes/total) * 100}%)</li>
      ]]
  </ul>
]=]

local function block_poll_total(app, args, tmpl)
  tmpl = tmpl or template.compile(poll_total_tmpl)
  return function (web, env, name)
	   local poll = env.node
	   return tmpl:render(web, poll)
	 end
end

local function post_vote(app, web, params)
  web:content_type("application/json")
  local id = tonumber(params.id)
  local poll = app.nodes.poll:find(id)
  if poll then
    local obj = json.decode(web.input.json)
    local options = app.nodes.poll.option:find_all_by_poll{ poll.id }
    local ok, err = poll:vote(obj.option, options)
      if ok then
        return json.encode{}
      else
        return json.encode{ message = err }
      end
  else
    return json.encode{ message = "Poll not found" }
  end
end

function plugin.new(app)
  schema.loadstring([[
    poll = entity {
      parent = "node",
      fields = {
        total = integer(),
	closed = boolean()
      }
    }
    poll_option = entity {
      fields = {
	id = key(),
	name = text(),
	weight = integer(),
	votes = integer(),
	poll = belongs_to{ "poll" }
      }
    }
  ]], "@poll.lua", app.mapper.schema)

  app.nodes.poll = app:model("poll")
  app.nodes.poll.option = app:model("poll_option")

  function app.nodes.poll:find_latest()
    local poll = self:find_first("closed is null or closed != ?", 
	{ true, order = "created_at desc", count = 1 })
    if poll then
      poll.options = self.option:find_all_by_poll{ poll.id, order = "weight desc" }
      return poll
    end
  end

  function app.nodes.poll:vote(option_id, options)
    for _, option in ipairs(options) do
      if option.id == option_id then
        self.total = self.total + 1
        self:save()
        option.votes = option.votes + 1
        option:save()
        break
      end
    end
  end

  app.blocks.protos.latest_poll = block_poll
  app.blocks.protos.poll_total = block_poll_total
  table.insert(app.routes, { pattern = R'/poll/:id/vote', handler = post_vote, method = "post" })
  app.nodes.types.poll = {}
end

return plugin
