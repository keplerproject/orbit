## Orbit Example

This page documents the Blog example in the `samples/` folder of 
[Orbit](http://orbit.luaforge.net)'s distribution. It is in the "literate programming" style, with code and
explantion insterspersed. The Blog example exercises most of the current
features of Orbit, and can be easily changed to suit the needs of
similar dynamic web sites.

## Initialization

First let's require Orbit itself and the other libraries that the Blog uses (the
SQLite3 LuaSQL driver and the Markdown parser). After that we declare
that the Blog is a Lua module, and an Orbit application by passing the
`orbit.app` option to `module`. Finally we load the application's configuration
data.

<pre>
require "orbit"
require "luasql.sqlite3"
require "markdown"

module("blog", package.seeall, orbit.app)

require "blog_config"
</pre>

`orbit.app` injects quite a lot of stuff in the `blog` module's namespace.
The most important of these are the `add_models`, `add_controllers` and
`add_views` methods that let you define the main functionality of the
application. It also defines a `mapper` variable that Orbit uses to create
the models (Orbit initializes this variable to its default ORM mapper). Finally,
it defines default controllers for 404 and 500 HTTP error codes as the
`not_found` and `server_error` variables, respectively. Override those if you
want custom pages for your application.

<pre>
local env = luasql[database.driver]()
mapper.conn = env:connect(database.conn_string)
</pre>

The code above initializes the DB connection for Orbit's default mapper. You need
to do this before creating the models because Orbit's default mapper hits the
database on model creation to fetch the DB metadata.

## Models

Now we are going to define the model part of the application. We do this by
calling `add_models`, passing a table with the models we want to create.
Orbit calls the mapper's `new` method for each model, passing the model
name and the table with your model's methods.

<pre>
blog:add_models{
</pre>

The first model we define is the `post` model. The default mapper will try to find
posts in a table called `blog_post` in the database. The `id` column is assumed
to be the primary key of the table.

<pre>
  post = {
    find_comments = function (self)
      return models.comment:find_all_by_post_id{ self.id }
    end,
    find_recent = function (self)
      return self:find_all("published_at not null",
                           { order = "published_at desc",
                             count = recent_count })
    end,
    find_by_month_and_year = function (self, month, year)
      local s = os.time({ year = year, month = month, day = 1 })
      local e = os.time({ year = year + math.floor(month / 12),
                          month = (month % 12) + 1,
                          day = 1 })
      return self:find_all("published_at >= ? and published_at < ?",
                               { s, e, order = "published_at desc" })
    end,
    find_months = function (self)
      local months = {}
      local previous_month = {}
      local posts = self:find_all({ order = "published_at desc" })
      for _, post in ipairs(posts) do
        local date = os.date("*t", post.published_at)
        if previous_month.month ~= date.month or
           previous_month.year ~= date.year then
          previous_month = { month = date.month, year = date.year }
          months[#months + 1] = previous_month
        end
      end
      return months
    end
  },
</pre>

There is no distinction between "class methods" and "instance methods" for models.
You define both of them inside the model table, and it is your responsibility to
not mix them up when you use your models. But this shouldn't be a surprise to Lua
users. In the case of the `post` model, all of the methods are "class methods", more
specifically finders. The default mapper defines a few generic finder methods, and
also creates tailored finders (such as `find_all_by_post_id` used in `find_comments`
on demand. Their use above should be self-explanatory.

The next model we declare is the `comment` model. It is much simpler,
with no custom finders, but it does have an "instance method" that
we use later in the view part of the application.

<pre>
  comment = {
    make_link = function (self)
      local author = self.author or anonymous_author
      if self.url and self.url ~= "" then
        return author, self.url
      elseif self.email and self.email ~= "" then
        return author, "mailto:" .. self.email
      else
        return author
      end
    end
  },
</pre>

Finally the `page` model just needs the default functionality, so we just
declare it as an empty table.

<pre>
  page = {}
}
</pre>

## Controllers

Now we are going to define the controllers of the application. In Orbit, each
controller has a list of patterns that Orbit matches against the `PATH_INFO`
to find the correct controller, and http methods that this controller handlers.
Each method receives the running application instance, and any captures
by the pattern.

<pre>
blog:add_controllers{
</pre>

The `index` controller shows all recent posts, and is pretty straightforward. All
GET requests to `/` or `/index` will go to this controller. It just fetches the
required model data from the database, then passes control to the `index`
view along with the model data.

<pre>
  index = { "/", "/index",
    get = function(app)
      local posts = blog.models.post:find_recent()
      local months = blog.models.post:find_months()
      local pages = blog.models.page:find_all()
      app:render("index", { posts = posts, months = months,
                    recent = posts, pages = pages })
    end
  },
</pre>

The `post` controller shows a single post (and its comments). Any GET requests
to `/post/{post_id}` go to it. It is pretty similar to `index`, as most of the model
data that it has to load is the same (to render the nav bar, menu, and archive links).
Notice how `post` delegates to `not_found` when the post does not exist.

<pre>
  post = { "/post/(%%d+)",
    get = function (app, post_id)
      local post = blog.models.post:find(tonumber(post_id))
      local recent = blog.models.post:find_recent()
      local pages = blog.models.page:find_all()
      if post then
        post.comments = post:find_comments()
        local months = blog.models.post:find_months()
        app:render("post", { post = post, months = months,
                     recent = recent, pages = pages })
      else
        app.not_found.get(app)
      end
    end
  },
</pre>

The `add_comment` model is the biggest, and most complicated, as it has
to handle POST methods. It also does some validation on the input. If the
comment field is empty it delegates back to the `post` controller, along with
a flag that will make the view display the appropriate error message. If not it
creates a new comment model object, fills it up and then writes it to the database.
The comment's `created_at` field is automatically set to the current time by
Orbit's model mapper. The controller also updates the comment count in
the post object. Finally, it redirects to the post page. The redirect avoids double
posting in case the user hits reload.

<pre>
  add_comment = { "/post/(%%d+)/addcomment",
    post = function (app, post_id)
      if string.find(app.input.comment, "^%s*$") then
        blog.controllers.post.get(app, post_id, true)
      else
        local comment = blog.models.comment:new()
        comment.post_id = tonumber(post_id)
        comment.body = markdown(app.input.comment)
        if not string.find(app.input.author, "^%s*$") then
          comment.author = app.input.author
        end
        if not string.find(app.input.email, "^%s*$") then
          comment.email = app.input.email
        end
        if not string.find(app.input.url, "^%s*$") then
          comment.url = app.input.url
        end
        comment:save()
        local post = blog.models.post:find(tonumber(post_id))
        post.n_comments = (post.n_comments or 0) + 1
        post:save()
        app:redirect("/post/" .. post_id)
      end
    end
  },
</pre>

The next controller is straightforward, and renders a page with the posts for the given month and year (the same view that the index uses). A method we defined in the post model gets the posts we want (and in the order we want them). 

<pre>
  archive = { "/archive/(%%d+)/(%%d+)",
    get = function (app, year, month)
      local posts = blog.models.post:find_by_month_and_year(tonumber(month),
                                                            tonumber(year))
      local months = blog.models.post:find_months()
      local recent = blog.models.post:find_recent()
      local pages = blog.models.page:find_all()
      app:render("index", { posts = posts, months = months,
                            recent = recent, pages = pages })
    end
  },
</pre>

The `page` controller below handles "static" pages of the blog (the links that appear in the navigation menu). Also straightforward, most of this is boilerplate that all controllers have, to feed some of the layout elements (the navigation menu and parts of the sidebar).

<pre>
  page = { "/page/(%%d+)",
    get = function (app, page_id)
      local page = blog.models.page:find(tonumber(page_id))
      if page then
        local recent = blog.models.post:find_recent()
        local months = blog.models.post:find_months()
        local pages = blog.models.page:find_all()
        app:render("page", { page = page, months = months,
                    recent = recent, pages = pages })
      else
        app.not_found.get(app)
      end
    end
  },
</pre>

Finally, the next two controllers serve the header image and the style sheet out of the filesystem. They are here so the application won't rely on any server configuration to run (just the default `orbit blog.lua` in the application's directory). In a production deployment you should delegate this task to your webserver.

<pre>
  header = { "/head%%.jpg",
    get = function (self, name, ext)
      self.headers["Content-Type"] = "image/jpg"
      local img = io.open("head.jpg")
      self.response = img:read("*a")
      img:close()
    end
  },
  style = { "/style%%.css",
    get = function (self)
      self.headers["Content-Type"] = "text/css; charset=utf-8"
      local file = io.open("style.css")
      self.response = file:read("*a")
      file:close()
    end
  }
}
</pre>

