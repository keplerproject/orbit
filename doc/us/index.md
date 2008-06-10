## Overview

Orbit is an MVC web framework for Lua. The design is inspired by lightweight Ruby
frameworks such as [Camping](http://code.whytheluckystiff.net/camping/). It completely
abandons the current CGILua model of "scripts" in favor of applications, where each Orbit
application can fit in a single file, but you can split it into multiple files if you want.
All Orbit applications follow the [WSAPI](http://wsapi.luaforge.net) protocol, so currently
work with Xavante,
CGI and Fastcgi. It includes a launcher that makes it easy to launch a Xavante instance for
development.

## History

* Version 2.0.1: bug-fix release, fixed bug in Orbit pages' redirect function (thanks for
Ignacio Burgueño for finding the bug)

* Version 2.0: Complete rewrite of Orbit

* Version 1.0: Initial release, obsolete

## Hello World

Below is a very simple Orbit application:

<pre>
    #!/usr/bin/env wsapi.cgi

    require"orbit"

    -- Orbit applications are usually modules,
    -- orbit.new does the necessary initialization

    module("hello", package.seeall, orbit.new)

    -- These are the controllers, each receives a web object
    -- that is the request/response, plus any extra captures from the
    -- dispatch pattern. The controller sets any extra headers and/or
    -- the status if it's not 200, then return the response. It's
    -- good form to delegate the generation of the response to a view
    -- function

    function index(web)
      return render_index()
    end

    function say(web, name)
      return render_say(web, name)
    end

    -- Builds the application's dispatch table, you can
    -- pass multiple patterns, and any captures get passed to
    -- the controller

    hello:dispatch_get(index, "/", "/index")
    hello:dispatch_get(say, "/say/(%a+)")

    -- These are the view functions referenced by the controllers.
    -- orbit.htmlify does through the functions in the table passed
    -- as the first argument and tries to match their name against
    -- the provided patterns (with an implicit ^ and $ surrounding
    -- the pattern. Each function that matches gets an environment
    -- where HTML functions are created on demand. They either take
    -- nil (empty tags), a string (text between opening and
    -- closing tags), or a table with attributes and a list
    -- of strings that will be the text. The indexing the
    -- functions adds a class attribute to the tag. Functions
    -- are cached.
    --

    -- This is a convenience function for the common parts of a page

    function render_layout(inner_html)
       return html{
         head{ title"Hello" },
         body{ inner_html }
       }
    end

    function render_hello()
       return p.hello"Hello World!"
    end
    
    function render_index()
       return render_layout(render_hello())
    end

    function render_say(web, name)
       return render_layout(render_hello() .. 
         p.hello((web.input.greeting or "Hello ") .. name .. "!"))
    end

    orbit.htmlify(hello, "render_.+")

    return _M
</pre>

The example uses Orbit's built-in html generation, but you are free to use any method of generating HTML. 
One of Orbit's sample applications uses the [Cosmo](http://cosmo.luaforge.net) template library, for instance.

## OR Mapping

Orbit also includes a basic OR mapper that currently only works with 
[LuaSQL's](http://luaforge.net/projects/luasql) SQLite3 and MySQL drivers. The mapper provides
dynamic find methods, a la Rails' ActiveRecord (find\_by\_field1\_and\_field2{val1, val2}),
as well as templates for conditions (find_by("field1 = ? or field1 = ?", { val1, val2 })). 
The sample applications use this mapper.

A nice side-effect of the Orbit application model is that we get an "application console" 
for free. For example, with the blog example we can add a new post like this:

<pre>
    $ lua -l luarocks.require -i blog.lua
    > p = blog.posts:new()
    > p.title = "New Post"
    > p.body = "This is a new blog post. Include *Markdown* markup freely."
    > p.published_at = os.time()
    > p:save()
</pre>

You can also update or delete any of the model items right from your console, just fetch 
them from the database, change what you want and call `save()` 
(or `delete()` if you want to remove it).

## Download and Installation

The easiest way to download and install Orbit is via [LuaRocks](http://luarocks.org). You 
can install Orbit with a simple `luarocks install orbit`. Go to the path where LuaRocks
put Orbit to see the sample apps and this documentation. LuaRocks will automatically fetch
and install any dependencies you don't already have.

You can also get Orbit from [LuaForge](http://luaforge.net/projects/orbit). 
Installing in Unix-like systems is "configure && make && make install", but you have to install
any dependencies (such as WSAPI and Xavante) yourself.
 
## Credits

Orbit was designed and developed by Fabio Mascarenhas and André Carregal,
and is maintained by Fabio Mascarenhas.

## Contact Us

For more information please [contact us](mailto:info-NO-SPAM-THANKS@keplerproject.org).
Comments are welcome!

You can also reach us and other developers and users on the Kepler Project 
[mailing list](http://luaforge.net/mail/?group_id=104). 


