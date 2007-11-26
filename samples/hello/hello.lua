require"orbit"

-- An application must be a module
-- orbit.app adds the controllers, views and new methods
-- to the module.

module("hello", package.seeall, orbit.app)

-- Numerical indexes for controllers have routes (^ and $ are
-- appended to the patterns automatically). If there are no
-- patterns Orbit assumes /controller_name
--
-- HTTP methods are the functions, they receive any
-- captures in the pattern. self is a reference to the application
-- object (instance of an application). self.controllers is the
-- table of controllers
--
-- render is one of the methods that application instances
-- respond to. It renders a view with optional arguments
--

hello:add_controllers{
  index = { "/",
    get = function(self)
            self:render("index")
          end
  },

  say = { "/say/(%a+)",
    get = function(self, name)
            self:render("say", { name = name })
          end
  }
}

-- Each view is a function that optionally takes a table
-- of arguments. layout is a special view that, if present,
-- is always called, and has the call to yield() inside
-- it replaced with the text from the view.
--
-- HTML functions are created on demand. They either take
-- nil (empty tags), a string (text between opening and
-- closing tags), or a table with attributes and a list
-- of strings that will be the text. The indexing the
-- functions adds a class attribute to the tag. Functions
-- are cached.
--
-- html generator functions are part of the global
-- environment of each view function. self is a reference
-- to the application instance. Use the render_partial method to call
-- another view. It does not use layout.
--

hello:add_views{
  layout = function (self)
             return html{
                       head{ title"Hello" },
                       body{ view() }
                    }
           end,

  index = function (self)
            return p.hello"Hello World!"
          end,

  say = function(self, args)
          return self:render_partial("index") .. 
	    p.hello((self.input.greeting or "Hello ") .. args.name .. "!")
        end
}

