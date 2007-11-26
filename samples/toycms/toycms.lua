require"orbit"
require"luasql.sqlite3"
require"markdown"
require"cosmo"

module("toycms", package.seeall, orbit.app)

require"toycms_config"

local env = luasql[database.driver]()
mapper.conn = env:connect(database.conn_string)

toycms.prefix = url_prefix 

toycms:add_models{
  post = {
    find_comments = function (self)
      return toycms.models.comment:find_all_by_approved_and_post_id{ true,
	self.id }
    end,
    find_months = function (self, section_ids)
      local months = {}
      local previous_month = {}
      local posts = self:find_all_by_published_and_section_id{
	order = "published_at desc", true, section_ids }
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
  section = {
    find_by_tags = function (self, tags)
      return self:find_all("tag like ?", tags)
    end
  },
  user = {}
}

function toycms.methods:load_template(name)
  local template_file = io.open("templates/" ..
				template_name .. "/" .. name)
  if template_file then
    local template = template_file:read("*a")     
    template_file:close()
    return template
  else
    return nil
  end
end

function toycms.methods:new_template_env()
  local template_env = {}

  template_env.template_vpath = template_vpath or self:link("/template")
  template_env.js_vpath = js_vpath or self:link("/javascripts")
  template_env.today = date(os.time())
  template_env.home_url = self:link("/")
  template_env.home_url_xml = self:link("/xml")

  function template_env.import(arg)
    local plugin_name = arg[1]
    for fname, f in pairs(plugins[plugin_name](self)) do
      template_env[fname] = f
    end
    return ""
  end

  return template_env
end

function toycms.methods:new_section_env(section)
  local env = self:new_template_env()
  env.id = section.id
  env.title = section.title
  env.description = section.description
  env.tag = section.tag
  env.uri = self:link("/section/" .. section.id)
  return env
end

function toycms.methods:new_post_env(post, section)
  local env = self:new_template_env()
  env.id = post.id
  env.title = post.title
  env.abstract = post.abstract
  env.body = cosmo.fill(post.body,
    { image_vpath = (image_vpath or self:link("/post")) .. "/" .. post.id })
  env.markdown_body = markdown(env.body)
  env.day_padded = os.date("%d", post.published_at)
  env.day = tonumber(env.day_padded)
  env.month_name = month_names[tonumber(os.date("%m",
    post.published_at))]
  env.month_padded = os.date("%m", post.published_at)
  env.month = tonumber(env.month_padded)
  env.year = tonumber(os.date("%Y", post.published_at))
  env.short_year = os.date("%y", post.published_at)
  env.hour_padded = os.date("%H", post.published_at)
  env.minute_padded = os.date("%M", post.published_at)
  env.hour = tonumber(env.hour_padded)
  env.minute = tonumber(env.minute_padded)
  env.date_string = date(post.published_at)
  if self:empty(post.external_url) then
    env.uri = self:link("/post/" .. post.id)
  else
    env.uri = post.external_url
  end
  env.n_comments = post.n_comments or 0
  env.section_uri = self:link("/section/" .. post.section_id)
  section = section or self.models.section:find(post.section_id) 
  env.section_title = section.title
  env.image_uri = (image_vpath or self:link("/post")) .. "/" .. post.id ..
    "/" .. (post.image or "")
  env.if_image = cosmo.cond(not self:empty(post.image), env)
  local form_env = {}
  form_env.author = self.input.author or ""
  form_env.email = self.input.email or ""
  form_env.url = self.input.url or ""
  setmetatable(form_env, { __index = env })
  env.if_comment_open = cosmo.cond(post.comment_status ~= "closed", form_env)
  env.if_error_comment = cosmo.cond(not self:empty_param("error_comment"), env)
  env.if_comments = cosmo.cond((post.n_comments or 0) > 0, env)
  env.comments = function (arg, has_block)
    local do_list = function ()
      local comments = post:find_comments()
      for _, comment in ipairs(comments) do
        cosmo.yield(self:new_comment_env(comment))
      end
    end
    if has_block then do_list()
    else
      local template_file = (arg and arg.template) or "comment.html"
      local template = self:load_template(template_file)
      return cosmo.fill("$do_list[[" .. template .. "]]",
        { do_list = do_list })
    end
  end
  env.add_comment_uri = self:link("/post/" .. post.id .. "/addcomment")
  return env
end

function toycms.methods:new_comment_env(comment)
  local env = self:new_template_env()
  env.author_link = comment:make_link()
  env.body = comment.body
  env.markdown_body = markdown(env.body)
  env.time_string = time(comment.created_at)
  env.day_padded = os.date("%d", comment.created_at)
  env.day = tonumber(env.day_padded)
  env.month_name = month_names[tonumber(os.date("%m",
    comment.created_at))]
  env.month_padded = os.date("%m", comment.created_at)
  env.month = tonumber(env.month_padded)
  env.year = tonumber(os.date("%Y", comment.created_at))
  env.short_year = os.date("%y", comment.created_at)
  env.hour_padded = os.date("%H", comment.created_at)
  env.minute_padded = os.date("%M", comment.created_at)
  env.hour = tonumber(env.hour_padded)
  env.minute = tonumber(env.minute_padded)
  return env
end

require"toycms_plugins"

toycms:add_controllers{
  home_page = { "/", "/index",
    get = function (app)
      local template = app:load_template("home.html")
      if template then
        app:render("index", { template = template,
		     env = app:new_template_env() })
      else
        app.not_found.get(app)
      end
    end
  },
  home_xml = { "/xml",
    get = function (app)
      local template = app:load_template("home.xml")
      if template then
	app.headers["Content-Type"] = "text/xml"
	app.response = cosmo.fill(template, app:new_template_env())
      else
        app.not_found.get(app)
      end
    end
  },
  section = { "/section/(%d+)",
    get = function (app, section_id)
      local section = app.models.section:find(tonumber(section_id))
      if not section then return app.not_found.get(app) end
      local template = app:load_template("section_" .. 
					 tostring(section.tag) .. ".html") or
                       app:load_template("section.html")
      if template then
	app.input.section_id = tonumber(section_id)
	app:render("section", { template = template, section = section })
      else
	app.not_found.get(app)
      end
    end
  },
  section_xml = { "/section/(%d+)/xml",
    get = function (app, section_id)
      local section = app.models.section:find(tonumber(section_id))
      if not section then return app.not_found.get(app) end
      local template = app:load_template("section_" .. 
					 tostring(section.tag) .. ".xml") or
                       app:load_template("section.xml")
      if template then
	app.input.section_id = tonumber(section_id)
	local env = app:new_section_env(section)
	app.headers["Content-Type"] = "text/xml"
	app.response = cosmo.fill(template, env)
      else
	app.not_found.get(app)
      end
    end
  },
  post = { "/post/(%d+)",
    get = function (app, post_id)
      local post = app.models.post:find(tonumber(post_id))
      if not post then return app.not_found.get(app) end
      local section = app.models.section:find(post.section_id)
      local template = app:load_template("post_" .. 
					 tostring(section.tag) .. ".html") or
                       app:load_template("post.html")
      if template then
	app.input.section_id = post.section_id
	app.input.post_id = tonumber(post_id)
	app:render("post", { template = template, post = post,
		     section = section })
      else
	app.not_found.get(app)
      end
    end
  },
  post_xml = { "/post/(%d+)/xml",
    get = function (app, post_id)
      local post = app.models.post:find(tonumber(post_id))
      if not post then return app.not_found.get(app) end
      local section = app.models.section:find(post.section_id)
      local template = app:load_template("post_" .. 
					 tostring(section.tag) .. ".xml") or
                       app:load_template("post.xml")
      if template then
	app.input.section_id = post.section_id
	app.input.post_id = tonumber(post_id)
        local env = app:new_post_env(post, section)
	app.headers["Content-Type"] = "text/xml"
        app.response = cosmo.fill(template, env)
      else
	app.not_found.get(app)
      end
    end
  },
  archive = { "/archive/(%d+)/(%d+)",
    get = function (app, year, month)
      local template = app:load_template("archive.html")
      if template then
	app.input.month = tonumber(month)
	app.input.year = tonumber(year)
	local env = app:new_template_env()
	env.archive_month = app.input.month
	env.archive_month_name = month_names[app.input.month]
	env.archive_year = app.input.year
	env.archive_month_padded = month
        app:render("index", { template = template, env = env })
      else
        app.not_found.get(app)
      end
    end
  },
  add_comment = { "/post/(%d+)/addcomment",
    post = function (app, post_id)
      if app:empty_param("comment") then
	app.input.error_comment = "1"
	app:redirect(app:link("/post/" .. post_id, app.input))
      else
        local post = models.post:find(tonumber(post_id))
	if app:empty(post.comment_status) or 
	   post.comment_status == "closed" then
          app:redirect(app:link("/post/" .. post_id))
        else
          local comment = app.models.comment:new()
          comment.post_id = post.id
  	  local body = string.gsub(app.input.comment, "<", "&lt;")
	  body = string.gsub(body, ">", "&gt;")
          comment.body = markdown(body)
          if not app:empty_param("author") then
	    comment.author = app.input.author
	  end
          if not app:empty_param("email") then
	    comment.email = app.input.email
	  end
          if not app:empty_param("url") then
	    comment.url = app.input.url
	  end
	  if post.comment_status == "unmoderated" then
	    comment.approved = true
	    post.n_comments = (post.n_comments or 0) + 1
	    post:save()
          else comment.approved = false end
          comment:save()
          app:redirect(app:link("/post/" .. post_id))
        end
      end
    end
  },
  style = { "/template/(.-%.css)",
    get = function (app, file_name)
      local style_file = io.open("templates/" .. 
				 template_name .. "/" .. file_name)
      if style_file then
	local style = style_file:read("*a")
	style_file:close()
	app.headers["Content-Type"] = "text/css; charset=utf-8"
	app.response = style
      else
        app.not_found.get(app)
      end
    end
  },
  images_gif = { "/template/images/(.-%.gif)",
    get = function (app, file_name)
      local image_file = io.open("templates/" .. 
				 template_name .. "/images/" .. file_name)
      if image_file then
	local image = image_file:read("*a")
	image_file:close()
	app.headers["Content-Type"] = "image/gif"
	app.response = image
      else
        app.not_found.get(app)
      end
    end
  },
  images_jpg = { "/template/images/(.-%.jpg)",
    get = function (app, file_name)
      local image_file = io.open("templates/" ..
				 template_name .. "/images/" .. file_name)
      if image_file then
	local image = image_file:read("*a")
	image_file:close()
	app.headers["Content-Type"] = "image/jpg"
	app.response = image
      else
        app.not_found.get(app)
      end
    end
  },
  images_png = { "/template/images/(.-%.png)",
    get = function (app, file_name)
      local image_file = io.open("templates/" ..
				 template_name .. "/images/" .. file_name)
      if image_file then
	local image = image_file:read("*a")
	image_file:close()
	app.headers["Content-Type"] = "image/png"
	app.response = image
      else
        app.not_found.get(app)
      end
    end
  },
  images_post = { "/post/(%d+)/(.-%.jpg)",
    get = function (app, post_id, file_name)
      local image_file = io.open("images/" .. post_id .. "/" .. file_name)
      if image_file then
	local image = image_file:read("*a")
	image_file:close()
	app.headers["Content-Type"] = "image/jpg"
	app.response = image
      else
        app.not_found.get(app)
      end
    end
  },
  javascript = { "/javascripts/(.-%.js)",
    get = function (app, file_name)
      local js_file = io.open("scriptaculous/" .. file_name)
      if js_file then
	local js = js_file:read("*a")
	js_file:close()
	app.headers["Content-Type"] = "application/x-javascript"
	app.response = js
      else
        app.not_found.get(app)
      end
    end
  }
}

toycms:add_views{
  layout = function (app)
    local layout_template = app:load_template("layout.html")
    if layout_template then
      local env = app:new_template_env()
      env.view = view()
      return cosmo.fill(layout_template, env)
    else
      return view()
    end
  end,
  index = function (app, params)
    return cosmo.fill(params.template, params.env)
  end,
  section = function (app, params)
    local env = app:new_section_env(params.section)
    return cosmo.fill(params.template, env)
  end,
  post = function (app, params)
    local env = app:new_post_env(params.post, params.section)
    return cosmo.fill(params.template, env)
  end
}

function toycms.methods:check_user()
  local user_id = self.cookies.user_id
  local password = self.cookies.password
  return self.models.user:find_by_id_and_password{ user_id, password }
end

require"toycms_admin"

