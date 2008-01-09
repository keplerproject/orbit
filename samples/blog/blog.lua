require "orbit"
require "markdown"

--
-- Declares that this is module is an Orbit app
--
module("blog", package.seeall, orbit.app)

--
-- Loads configuration data
--
require"blog_config"

--
-- Initializes DB connection for Orbit's default model mapper
--
require("luasql." .. database.driver)
local env = luasql[database.driver]()
mapper.conn = env:connect(unpack(database.conn_data))

--
-- Models for this application. Orbit calls mapper:new for each model,
-- so if you want to replace Orbit's default ORM mapper by another
-- one (file-based, for example) just redefine the mapper global variable
--
blog:add_models{
  post = {
    find_comments = function (self)
      return models.comment:find_all_by_post_id{ self.id }
    end,
    find_recent = function (self)
      return self:find_all("published_at is not null",
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
  comment = {
    make_link = function (self)
      local author = self.author or strings.anonymous_author
      if self.url and self.url ~= "" then
        return "<a href=\"" .. self.url .. "\">" .. author .. "</a>"
      elseif self.email and self.email ~= "" then
        return "<a href=\"mailto:" .. self.email .. "\">" .. author .. "</a>"
      else
        return author
      end
    end
  },
  page = {}
}

--
-- Controllers for this application
--
blog:add_controllers{
  index = { "/", "/index",
    get = function (self)
      local posts = models.post:find_recent()
      local months = models.post:find_months()
      local pages = models.page:find_all()
      self:render("index", { posts = posts, months = months,
		    recent = posts, pages = pages })
    end
  },
  post = { "/post/(%d+)",
    get = function (self, post_id, comment_missing)
      local post = models.post:find(tonumber(post_id))
      if post then
	local recent = models.post:find_recent()
	local pages = models.page:find_all()
	post.comments = post:find_comments()
	local months = models.post:find_months()
	self:render("post", { post = post, months = months,
		     recent = recent, pages = pages,
		     comment_missing = comment_missing })
      else
	self.not_found.get(self)
      end
    end
  },
  add_comment = { "/post/(%d+)/addcomment",
    post = function (self, post_id)
      if string.find(self.input.comment, "^%s*$") then
	controllers.post.get(self, post_id, true)
      else
        local comment = models.comment:new()
        comment.post_id = tonumber(post_id)
        comment.body = markdown(self.input.comment)
        if not string.find(self.input.author, "^%s*$") then
	  comment.author = self.input.author
	end
        if not string.find(self.input.email, "^%s*$") then
	  comment.email = self.input.email
	end
        if not string.find(self.input.url, "^%s*$") then
	  comment.url = self.input.url
	end
        comment:save()
        local post = models.post:find(tonumber(post_id))
	post.n_comments = (post.n_comments or 0) + 1
	post:save()
        self:redirect("/post/" .. post_id)
      end
    end
  },
  archive = { "/archive/(%d+)/(%d+)",
    get = function (self, year, month)
      local posts = models.post:find_by_month_and_year(tonumber(month),
						       tonumber(year))
      local months = models.post:find_months()
      local recent = models.post:find_recent()
      local pages = models.page:find_all()
      self:render("index", { posts = posts, months = months,
		    recent = recent, pages = pages })
    end
  },
  background = { "/(head)%.(jpg)",
    get = function (self, name, ext)
      self.headers["Content-Type"] = "image/" .. ext
      local img = io.open(name .. "." .. ext, "rb")
      self.response = img:read("*a")
      img:close()
    end
  },
  style = { "/style%.css",
    get = function (self)
      self.headers["Content-Type"] = "text/css; charset=utf-8"
      local file = io.open("style.css")
      self.response = file:read("*a")
      file:close()
    end
  },
  page = { "/page/(%d+)",
    get = function (self, page_id)
      local page = models.page:find(tonumber(page_id))
      if page then
        local recent = models.post:find_recent()
        local months = models.post:find_months()
        local pages = models.page:find_all()
        self:render("page", { page = page, months = months,
		    recent = recent, pages = pages })
      else
	self.not_found.get(self)
      end
    end
  },
}

--
-- Views for this application
--
blog:add_views{
  layout = function (self, args)
      return html{
        head{
          title(blog_title),
	  meta{ ["http-equiv"] = "Content-Type",
	    content = "text/html; charset=utf-8" },
          link{ rel = 'stylesheet', type = 'text/css', 
               href = '/style.css', media = 'screen' }
        },
	body{
	  div{ id = "container",
	    div{ id = "header", title = "sitename" },
	    div{ id = "mainnav",
	      self:render_partial("_menu", args)
	    }, 
            div{ id = "menu",
	      self:render_partial("_sidebar", args)
	    },  
	    div{ id = "contents", view() },
	    div{ id = "footer", copyright_notice }
          }
        }
      } 
  end,
  _menu = function (self, args)
    local res = { li(a{ href= "/", strings.home_page_name }) }
    for _, page in pairs(args.pages) do
      res[#res + 1] = li(a{ href = "/page/" .. page.id, page.title })
    end
    return ul(res)
  end,
  _blogroll = function (self, blogroll)
    local res = {}
    for _, blog_link in ipairs(blogroll) do
      res[#res + 1] = li(a{ href=blog_link[1], blog_link[2] })
    end
    return ul(res)
  end,
  _sidebar = function (self, args)
    return {
      h3(strings.about_title),
      ul(li(about_blurb)),
      h3(strings.last_posts),
      self:render_partial("_recent", args),
      h3(strings.blogroll_title),
      self:render_partial("_blogroll", blogroll),
      h3(strings.archive_title),
      self:render_partial("_archives", args)
    }
  end,
  _recent = function (self, args)
    local res = {}
    for _, post in ipairs(args.recent) do
      res[#res + 1] = li(a{ href="/post/" .. post.id, post.title })
    end
    return ul(res)
  end,
  _archives = function (self, args)
    local res = {}
    for _, month in ipairs(args.months) do
      res[#res + 1] = li(a{ href="/archive/" .. month.year .. "/" ..
			   month.month, blog.month(month) })
    end
    return ul(res)
  end,
  index = function (self, args)
    if #args.posts == 0 then
      return p(strings.no_posts)
    else
      local res = {}
      local cur_time
      for _, post in pairs(args.posts) do
	local str_time = date(post.published_at)
	if cur_time ~= str_time then
	  cur_time = str_time
	  res[#res + 1] = h2(str_time)
  	end
        res[#res + 1] = h3(post.title)
        res[#res + 1] = self:render_partial("_post", post)
      end
      return div.blogentry(res)
    end
  end,
  _post = function (self, post)
    return {
      markdown(post.body),
      p.posted{ 
        strings.published_at .. " " .. 
          os.date("%H:%M", post.published_at), " | ",
	a{ href = "/post/" .. post.id .. "#comments", strings.comments ..
             " (" .. (post.n_comments or "0") .. ")" }
      }
    }
  end,
  _comment = function (self, comment)
    return { p(comment.body),
             p.posted{
               strings.written_by .. " " .. comment:make_link(),
               " " .. strings.on_date .. " " ..
               time(comment.created_at) 
             }
           }
  end,
  page = function (self, args)
    return div.blogentry(markdown(args.page.body))
  end,
  post = function (self, args)
    local res = { 
      h2(span{ style="position: relative; float:left", args.post.title }
        .. "&nbsp;"),
      h3(date(args.post.published_at)),
      self:render_partial("_post", args.post)
    }
    res[#res + 1] = a{ name = "comments" }
    if #args.post.comments > 0 then
      res[#res + 1] = h2(strings.comments)
      for _, comment in pairs(args.post.comments) do
	res[#res + 1 ] = self:render_partial("_comment", comment)
      end
    end
    res[#res + 1] = h2(strings.new_comment)
    local err_msg = ""
    if args.comment_missing then
      err_msg = span{ style="color: red", strings.no_comment }
    end
    res[#res + 1] = form{
      method = "post",
      action = "/post/" .. args.post.id .. "/addcomment",
      p{ strings.form_name, br(), input{ type="text", name="author" },
         br(), br(),
         strings.form_email, br(), input{ type="text", name="email" },
         br(), br(),
         strings.form_url, br(), input{ type="text", name="url" },
         br(), br(),
         strings.comments .. ":", br(), err_msg,
         textarea{ name="comment", rows="10", cols="60" }, br(),
         em(" *" .. strings.italics .. "* "),
         strong(" **" .. strings.bold .. "** "), 
         " [" .. a{ href="/url", strings.link } .. "](http://url) ",
         br(), br(),
         input.button{ type="submit", value=strings.send }
      }
    }
    return div.blogentry(res)
  end,
}
