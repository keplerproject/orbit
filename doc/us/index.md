## Overview

Orbit is an MVC web framework for Lua. The design is inspired by lightweight Ruby
frameworks such as [Camping](http://code.whytheluckystiff.net/camping/). It completely
abandons the current CGILua model of "scripts" in favor of applications. Each Orbit
application can fit in a single file, but you can split it into multiple files if you want.
All Orbit applications follow the [WSAPI](http://wsapi.luaforge.net) protocol, so currently
work with Xavante,
CGI and Fastcgi. It includes a launcher that makes it easy to launch a Xavante instance for
development.

## Hello World

Below is a very simple Orbit application:

<pre>
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
-- captures in the pattern. app is a reference to the application
-- object (instance of an application). app.controllers is the
-- table of controllers
--
-- render is one of the methods that application instances
-- respond to. It renders a view with optional arguments
--

hello:add_controllers{
  index = { "/",
    get = function (app)
            app:render("index")
          end
  },

  say = { "/say/(%a+)",
    get = function (app, name)
            app:render("say", { name = name })
          end
  }
}

-- Each view is a function that optionally takes a table
-- of arguments. layout is a special view that, if present,
-- is always called, and has the call to view() inside
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
-- environment of each view function. app is a reference
-- to the application instance. Use the render_partial method
-- to call another view. It does not use layout.
--

hello:add_views{
  layout = function (app)
             return html{
                       head{ title"Hello" },
                       body{ view() }
                    }
           end,

  index = function (app)
            return p.hello"Hello World!"
          end,

  say = function(app, args)
          return app:render_partial("index") .. 
  	        p.hello((self.input.greeting or "Hello") .. " ".. args.name .. "!")
        end
}
</pre>

The example uses Orbit's built-in html generation, but you are free to use any method of generating HTML that you want. One of Orbit's sample applications uses the [Cosmo](http://www.freewisdom.org/projects/sputnik/Cosmo) template library, for instance.

## OR Mapping

Orbit also includes a basic OR mapper that currently only works with [LuaSQL's](http://luaforge.net/projects/luasql) SQLite3 driver. The mapper provides dynamic search methods, a la Rails' ActiveRecord (find\_by\_field1\_and\_field2{val1, val2}), as well as templates for conditions (find_by("field1 = ? or field1 = ?", { val1, val2 })). The sample applications use this mapper.

A nice side-effect of the Orbit application model is that we get an "application console" for free. For example, with the blog example we can add a new post like this:

<pre>
$ lua51 -i blog.lua
> p = blog.models.post:new()
> p.title = "New Post"
> p.body = "This is a new blog post. Include *Markdown* markup freely."
> p.published_at = os.time()
> p:save()
</pre>

You can also update or delete any of the model items right from your console, just fetch them from the database, change what you want and call `save()` (or `delete()` if you want to remove it).

## Docs and download

There's not much documentation right now, apart from the source code and sample applications. A partial explanation of the Blog application is in [Orbit Blog Example](example.html). 

The only real dependency is [WSAPI](http://wsapi.luaforge.net), and it is included in the distribution via svn:externals (and installed together with Orbit). Installing the base Kepler (for Xavante) plus the SQLite3 driver is recommended (otherwise you only get CGI and no ORM). 

You can get the latest version from [LuaForge](http://luaforge.net/projects/orbit). Installing in Unix-like systems is "configure && make && make install". You can also get Orbit using [LuaRocks](http://luarocks.org), with "luarocks install orbit". This is the easiest way.

## Credits

Orbit was designed and developed by Fabio Mascarenhas and André Carregal,
and is maintained by Fabio Mascarenhas.

## Contact Us

For more information please [contact us](mailto:info-NO-SPAM-THANKS@keplerproject.org).
Comments are welcome!

You can also reach us and other developers and users on the Kepler Project 
[mailing list](http://luaforge.net/mail/?group_id=104). 


