
local schema = require "orbit.schema"

local plugin = { name = "mock_nodes" }

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
	term = has_and_belongs{ "term" }
      }
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
	display_name = text()
      }
    }
    term = entity {
      fields = {
	id = key(),
	vocabulary = belongs_to{ "vocabulary" },
	parent = has_one{ "term" },
	name = text(),
	display_name = text(),
	node = has_and_belongs{ "node" }
      }
    }
    node_term = entity{
      fields = {
        id = key(),
        node = belongs_to{ "node" },
        term = belongs_to{ "term" }
      }
    }
  ]], "@node.lua", app.mapper.schema)
  app.nodes.all = app:model("node")

  function app.nodes.all:find_latest(args)
    args = args or {}
    count = args.count or 10
    local in_home = { "home", "visibility", entity = "node_term", fields = { "id" },
	              condition = [[node_term.term = term.id and term.vocabulary = vocabulary.id and
	                            term.name = ? and vocabulary.name = ?]], from = { "term", "vocabulary" } }
    return self:find_all("id in ?", { in_home, order = "created_at desc", count = count })
  end

  function app.nodes:find_latest(args)
    return self.all:find_latest(args)
  end

  function app.nodes:find(id)
    return self.all:find(id)
  end

  function app.nodes:find_by_nice_id(nice_id)
    return self.all:find_by_nice_id{ nice_id }
  end
  
  app.nodes.post = app:model("post")

  function app.nodes.post:find_latest(args)
    args = args or {}
    count = args.count or 10
    return self:find_all("type = ?", { "post", order = "created_at desc", count = count })
  end

  app.nodes.types.post = app.nodes.post
end

return plugin
