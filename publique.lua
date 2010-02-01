
local core = require "modules.core"
local print = print
local ipairs = ipairs

module("publique", core.new)

local mock_nodes = {
  { id = 1, nice_id = "/post/foo", type = "post", title = "Foo", body = "<p>Lorem ipsum dolor</p>" },
  { id = 2, type = "post", title = "Bar", body = "<p>Foo bar baz bloop</p> <p>Boo.</p>" },
  { id = 3, nice_id = "/post/bar-blaz", type = "post", title = "Bar Blaz", body = "<p>Bar foo</p><ol><li>Foo</li><li>Bar</li></ol>" }
}

nodes.post = {
  find_latest = function ()
		  return mock_nodes
		end,
  find = function (self, id)
	   return mock_nodes[id]
	 end
}

nodes.find = function (self, id)
	       return mock_nodes[id]
	     end

nodes.find_by_nice_id = function (self, nice_id)
			  for _, node in ipairs(mock_nodes) do
			    if node.nice_id == nice_id then
			      return node
			    end
			  end
			end

nodes.types = { post = {} }

return _M.run
