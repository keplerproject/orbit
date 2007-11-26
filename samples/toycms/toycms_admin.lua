module("toycms", package.seeall)

-- Admin interface

toycms:add_controllers{
  admin = { "/admin", "/admin/(%d+)",
    get = function (app, section_id)
      if not app:check_user() then
        app:redirect(app:link("/login", { link_to = app:link("/admin") }))
      else
	local params = {}
	if tonumber(section_id) then
	  params.section = app.models.section:find(tonumber(section_id))
        end
        app:render("admin", params, "admin_layout")
      end
    end
  },
  login = { "/login",
    get = function (app)
      app:render("login", app.input, "admin_layout")	    
    end,
    post = function (app)
      local login = app.input.login
      local password = app.input.password
      local user = app.models.user:find_by_login{ login }
      if app:empty_param("link_to") then
	app.input.link_to = app:link("/")
      end
      if user then
	if password == user.password then
	  app:set_cookie("user_id", user.id)
	  app:set_cookie("password", user.password)
          app:redirect(app.input.link_to)
        else
	  app:redirect(app:link("/login", { login = login,
                                            link_to = app.input.link_to,
                                            not_match = "1" }))
        end
      else
	app:redirect(app:link("/login", { login = login,
                                          link_to = app.input.link_to,
                                          not_found = "1" }))
      end
    end
  },
  add_user = { "/adduser",
    get = function (app)
      if not app:check_user() then
	app:redirect(app:link("/login", { link_to = app:link("/adduser") }))
      else
        app:render("add_user", app.input, "admin_layout")
      end
    end,
    post = function (app)
      if not app:check_user() then
	app:redirect(app:link("/login", { link_to = app:link("/adduser") }))
      else
        local errors = {}
        if app:empty_param("login") then
	  errors.login = strings.blank_user
        end
        if app:empty_param("password1") then
          errors.password = strings.blank_password
        end
        if app.input.password1 ~= app.input.password2 then
          errors.password = strings.password_mismatch
        end
        if app:empty_param("name") then
          errors.name = strings.blank_name
        end
        if not next(errors) then
          local user = app.models.user:new()
          user.login = app.input.login
          user.password = app.input.password1
          user.name = app.input.name
          user:save()
          app:redirect(app:link("/admin"))
        else
	  for k, v in pairs(errors) do app.input["error_" .. k] = v end
          app:redirect(app:link("/adduser", app.input))
        end
      end
    end
  },
  edit_section = { "/editsection", "/editsection/(%d+)",
    get = function (app, section_id)
      if not app:check_user() then
	app:redirect(app:link("/login", { link_to = app:link("/editsection") }))
      else
	section_id = tonumber(section_id)
	if section_id then
	  app.input.section = app.models.section:find_by_id{ section_id }
	else
	  app.input.section = app.models.section:new()	
        end
        app:render("edit_section", app.input, "admin_layout")
      end
    end,
    post = function (app, section_id)
      if not app:check_user() then
	app:redirect(app:link("/login", { link_to = app:link("/editsection") }))
      else
        section_id = tonumber(section_id)
        local errors = {}
        if app:empty_param("title") then
	  errors.title = strings.blank_title
        end
        if not next(errors) then
	  local section
	  if section_id then
	    section = app.models.section:find_by_id{ section_id }
          else
	    section = app.models.section:new()
          end
	  section.title = app.input.title
	  section.description = app.input.description
	  section.tag = app.input.tag
	  section:save()
          app:redirect(app:link("/editsection/" .. section.id))
        else
	  for k, v in pairs(errors) do app.input["error_" .. k] = v end
  	  if section_id then
            app:redirect(app:link("/editsection/" .. section_id, app.input))
	  else
            app:redirect(app:link("/editsection", app.input))
          end
        end
      end
    end
  },
  delete_section = { "/deletesection/(%d+)",
    post = function (app, section_id)
      if not app:check_user() then
	app:redirect(app:link("/login", 
	  { link_to = app:link("/editsection/" .. section_id) }))
      else
	section_id = tonumber(section_id)
	local section = app.models.section:find(section_id)
	if section then
	  section:delete()
	  app:redirect(app:link("/admin"))
        end
      end   
    end
  },
  delete_post = { "/deletepost/(%d+)",
    post = function (app, post_id)
      if not app:check_user() then
	app:redirect(app:link("/login", 
	  { link_to = app:link("/editpost/" .. post_id) }))
      else
	post_id = tonumber(post_id)
	local post = app.models.post:find(post_id)
	if post then
	  post:delete()
	  app:redirect(app:link("/admin"))
        end
      end   
    end
  },
  edit_post = { "/editpost", "/editpost/(%d+)",
    get = function (app, post_id)
      if not app:check_user() then
	app:redirect(app:link("/login", { link_to = app:link("/editpost") }))
      else
	post_id = tonumber(post_id)
	if post_id then
	  app.input.post = app.models.post:find_by_id{ post_id }
	else
	  app.input.post = app.models.post:new()	
        end
	app.input.sections = app.models.section:find_all()
        app:render("edit_post", app.input, "admin_layout")
      end
    end,
    post = function (app, post_id)
      if not app:check_user() then
	app:redirect(app:link("/login", { link_to = app:link("/editpost") }))
      else
        post_id = tonumber(post_id)
        local errors = {}
        if app:empty_param("title") then
	  errors.title = strings.blank_title
        end
        if not next(errors) then
	  local post
	  if post_id then
	    post = app.models.post:find_by_id{ post_id }
          else
	    post = app.models.post:new()
          end
	  post.title = app.input.title
	  post.abstract = app.input.abstract
	  post.image = app.input.image
	  if app:empty_param("published_at") then
	    post.published_at = nil
	  else
	    local day, month, year, hour, minute =
              string.match(app.input.published_at,
			   "(%d+)-(%d+)-(%d+) (%d+):(%d+)")
	    post.published_at = os.time({ day = day, month = month,
					  year = year, hour = hour,
					  min = minute })
	  end
	  post.body = app.input.body
	  post.section_id = tonumber(app.input.section_id)
	  post.published = (not app:empty_param("published"))
	  post.external_url = app.input.external_url
	  post.in_home = (not app:empty_param("in_home"))
	  post.user_id = app:check_user().id
	  post.comment_status = app.input.comment_status
	  post:save()
          app:redirect(app:link("/editpost/" .. post.id))
        else
	  for k, v in pairs(errors) do app.input["error_" .. k] = v end
  	  if post_id then
            app:redirect(app:link("/editpost/" .. post_id, app.input))
	  else
            app:redirect(app:link("/editpost", app.input))
          end
        end
      end
    end
  },
  manage_comments = { "/comments",
    get = function (app)
      if not app:check_user() then
	app:redirect(app:link("/login", { link_to = app:link("/comments") }))
      else
	local params = {}
	local post_model = app.models.post
	params.for_mod = app.models.comment:find_all_by_approved{ false,
	  order = "created_at desc", inject = { model = post_model, 
	  fields = { "title" } } }
	params.approved = app.models.comment:find_all_by_approved{ true,
	  order = "created_at desc", inject = { model = post_model, 
	  fields = { "title" } } }
        app:render("manage_comments", params, "admin_layout")
      end
    end
  },
  approve_comment = { "/comment/(%d+)/approve",
    post = function (app, id)
      if not app:check_user() then
	app:redirect(app:link("/login", { link_to = app:link("/comments#" ..
							   id) }))
      else
	local comment = app.models.comment:find(tonumber(id))
	if comment then
	  comment.approved = true
	  comment:save()
	  local post = app.models.post:find(comment.post_id)
	  post.n_comments = (post.n_comments or 0) + 1
	  post:save()
  	  app:redirect(app:link("/comments#" .. id))
        end
      end
    end
  },
  delete_comment = { "/comment/(%d+)/delete",
    post = function (app, id)
      if not app:check_user() then
	app:redirect(app:link("/login", { link_to = app:link("/comments#" ..
							   id) }))
      else
	local comment = app.models.comment:find(tonumber(id))
	if comment then
	  if comment.approved then
  	    local post = app.models.post:find(comment.post_id)
	    post.n_comments = post.n_comments - 1
	    post:save()
          end
	  comment:delete()
  	  app:redirect(app:link("/comments"))
        end
      end
    end
  },
  admin_style = { "/admin/style%.css",
    get = function (app)
      app.response = [[
body
{
	margin: 0;
	padding: 0;
	font: 85% arial, hevetica, sans-serif;
	text-align: center;
	color: #000066;
	background-color: #FFFFFF;
}
a:link { color: #000066; }
a:visited { color: #0000CC; }
a:hover, a:active
{
	color: #CCCCFF;
	background-color: #000066;
}
a.button {
  color: #000066;
  text-decoration: none;
}
a.button:visited { color: #000066; }
a.button:hover { color: #000066; background-color: transparent; }
h2
{
	color: #000066;
	font: 140% georgia, times, "times new roman", serif;
	font-weight: bold;
	margin: 0 0 10px 0;
}
h3
{
	color: #000066;
	font: 106% georgia, times, "times new roman", serif;
	font-weight: bold;
	margin-top: 0;
}
#container
{
	margin: 1em auto;
	width: 720px;
	text-align: left;
	background-color: #FFFFFF;
	border: 1px none #0000CC;
}
#header
{
	color: #CCCCFF;
	background-color: #000088;
	height: 45px;
	width: 710px;
	border-bottom: 1px solid #0000CC;
	position: relative;
	border: 1px none #0000CC;
	border-bottom: 1px solid #0000CC;
	padding: 5px;
        text-align: right;
        font-size: 300%;
}
#mainnav ul { list-style-type: none; }
#mainnav li { display: inline; }
#menu
{
	float: right;
	width: 165px;
	border-left: 1px solid #0000CC;
	padding-left: 15px;
        padding-right: 15px;
        margin-bottom: 30px;
}
#contents { padding-right: 15px; margin: 0 200px 40px 20px; }
#contents p { line-height: 165%; }
.imagefloat { float: right; }
#footer
{
	clear: both;
	color: #CCCCFF;
        background-color: #0000CC;
	text-align: right;
	font-size: 90%;
}
#footer img
{
    vertical-align: middle;
}
#skipmenu
{
	position: absolute;
	left: 0;
	top: 5px;
	width: 645px;
	text-align: right;
}
#skipmenu a
{
	color: #666;
	text-decoration: none;
}
#skipmenu a:hover
{
	color: #fff;
	background-color: #666;
	text-decoration: none;
}
#container
{
	border: 1px solid #0000CC;
}
#mainnav
{
	background-color: #0000CC;
	color: #CCCCFF;
	padding: 2px 0;
	margin-bottom: 22px;
}
#mainnav ul
{
	margin: 0 0 0 20px;
	padding: 0;
	list-style-type: none;
	border-left: 1px solid #CCCCFF;
}
#mainnav li
{
	display: inline;
	padding: 0 10px;
	border-right: 1px solid #CCCCFF;
}
#mainnav li a
{
	text-decoration: none;
	color: #CCCCFF;
}
#mainnav li a:hover
{
	text-decoration: none;
	color: #0000CC;
	background-color: #CCCCFF;
}
#menu ul
{
	margin-left: 0;
	padding-left: 0;
	list-style-type: none;
	line-height: 165%;
}
.imagefloat
{
	padding: 2px;
	border: 1px solid #0000CC;
	margin: 0 0 10px 10px;
}
div.blogentry {
        padding-bottom: 30px;
}
.blogentry ul
{
    list-style-type: square;
    margin: 10px 0px 15px -10px;
}
.blogentry li
{
    line-height: 150%;
}
#footer
{
	background-color: #0000CC;
	padding: 5px;
	font-size: 90%;
}
]]
    end
  }
}

local function error_message(msg)
  return "<span style = \"color: red\">" ..  msg .. "</span>"
end

toycms:add_views{
  admin_layout = function(app, args)
      return html{
        head{
          title"ToyCMS Admin",
	  meta{ ["http-equiv"] = "Content-Type",
	    content = "text/html; charset=utf-8" },
          link{ rel = 'stylesheet', type = 'text/css', 
               href = app:link('/admin/style.css'), media = 'screen' }
        },
	body{
	  div{ id = "container",
	    div{ id = "header", title = "sitename", "ToyCMS Admin" },
	    div{ id = "mainnav",
	      ul {
		li{ a{ href = app:link("/admin"), strings.admin_home } },
		li{ a{ href = app:link("/adduser"), strings.new_user } },
		li{ a{ href = app:link("/editsection"), strings.new_section } },
		li{ a{ href = app:link("/editpost"), strings.new_post } },
		li{ a{ href = app:link("/comments"), strings.manage_comments } },
              }
	    }, 
            div{ id = "menu",
	      app:render_partial("_admin_menu", args)
	    },  
	    div{ id = "contents", view() },
	    div{ id = "footer", "Copyright 2007 Fabio Mascarenhas" }
          }
        }
      } 
  end,
  _admin_menu = function (app, params)
    local res = {}
    local user = app:check_user()
    if user then
      res[#res + 1] = ul{ li{ strings.logged_as, 
        (user.name or user.login) } }
      res[#res + 1] = h3(strings.sections)
      local section_list = {}
      local sections = app.models.section:find_all()
      for _, section in ipairs(sections) do
        section_list[#section_list + 1] = 
          li{ a{ href=app:link("/admin/" .. section.id), section.title } }
      end
      res[#res + 1] = ul(table.concat(section_list,"\n"))
    end
    return table.concat(res, "\n")
  end,
  admin = function (app, params)
    local section_list
    local sections = app.models.section:find_all({ order = "id asc" })
    if params.section then
      local section = params.section
      local res_section = {}
      res_section[#res_section + 1] = "<div class=\"blogentry\">\n"
 	res_section[#res_section + 1] = h2(strings.section .. ": " ..
          a{ href = app:link("/editsection/" .. section.id), section.title })
      local posts = app.models.post:find_all_by_section_id{ section.id,
        order = "published_at desc" }
      res_section[#res_section + 1] = "<p>"
      for _, post in ipairs(posts) do
	local in_home, published = "", ""
	if post.in_home then in_home = " [HOME]" end
        if post.published then published = " [P]" end
	res_section[#res_section + 1] = a{ href =
          app:link("/editpost/" .. post.id), post.title } .. in_home .. 
	  published .. br()
      end
      res_section[#res_section + 1] = "</p>"
      res_section[#res_section + 1] = 
      p{ a.button{ href = app:link("/editpost?section_id=" .. section.id), 
	  button{ strings.new_post } } }
      res_section[#res_section + 1] = "</div>\n"
      section_list = table.concat(res_section, "\n")      
    elseif next(sections) then
      local res_section = {}
      for _, section in ipairs(sections) do
        res_section[#res_section + 1] = "<div class=\"blogentry\">\n"
 	res_section[#res_section + 1] = h2(strings.section .. ": " ..
          a{ href = app:link("/editsection/" .. section.id), section.title })
	local posts = app.models.post:find_all_by_section_id{ section.id,
          order = "published_at desc" }
	res_section[#res_section + 1] = "<p>"
	for _, post in ipairs(posts) do
	  local in_home, published = "", ""
  	  if post.in_home then in_home = " [HOME]" end
          if post.published then published = " [P]" end
	  res_section[#res_section + 1] = a{ href =
            app:link("/editpost/" .. post.id), post.title } .. in_home .. 
	    published .. br()
        end
	res_section[#res_section + 1] = "</p>"
	res_section[#res_section + 1] = 
          p{ a.button { href = app:link("/editpost?section_id=" .. section.id),
	       button{ strings.new_post } } }
        res_section[#res_section + 1] = "</div>\n"
      end
      section_list = table.concat(res_section, "\n")
    else
      section_list = strings.no_sections
    end
    return div(section_list)
  end,
  login = function (app, params)
    local res = {}
    local err_msg = ""
    if params.not_match then
      err_msg = p{ error_message(strings.password_not_match) }
    elseif params.not_found then
      err_msg = p{ error_message(strings.user_not_found) }
    end
    res[#res + 1] = h2"Login"
    res[#res + 1] = err_msg
    res[#res + 1] = form{
      method = "post",
      action = app:link("/login"),
      input{ type = "hidden", name = "link_to", value = params.link_to },
      p{
        strings.login, br(), input{ type = "text", name = "login",
	  value = params.login or "" },
        br(), br(),
        strings.password, br(), input{ type = "password", name = "password" },
        br(), br(),
        input{ type = "submit", value = strings.login_button }
      }
    }
    return div(res)
  end,
  add_user = function (app, params)
    local error_login, error_password, error_name = "", "", ""
    if params.error_login then 
      error_login = error_message(params.error_login) .. br()
    end
    if params.error_password then 
      error_password = error_message(params.error_password) .. br()
    end
    if params.error_name then 
      error_name = error_message(params.error_name) .. br()
    end
    return div{
      h2(strings.new_user),
      form{
	method = "post",
	action = app:link("/adduser"),
        p{
          strings.login, br(), error_login, input{ type = "text",
            name = "login", value = params.login }, br(), br(),
          strings.password, br(), error_password, input{ type = "password",
            name = "password1" }, br(),
            input{ type = "password", name = "password2" }, br(), br(),
          strings.name, br(), error_name, input{ type = "text",
            name = "name", value = params.name }, br(), br(),
          input{ type = "submit", value = strings.add }
        }
      },
    }
  end,
  edit_section = function (app, params)
    local error_title = ""
    if params.error_title then
      error_title = error_message(params.error_title) .. br()
    end
    local page_header, button_text
    if not params.section.id then
      page_header = strings.new_section
      button_text = strings.add
    else
      page_header = strings.edit_section
      button_text = strings.edit
    end
    local action
    local delete
    if params.section.id then
      action = app:link("/editsection/" .. params.section.id)
      delete = form{ method = "post", action = app:link("/deletesection/" ..
	params.section.id), input{ type = "submit", value = strings.delete } }
    else
      action = app:link("/editsection")
    end
    return div{
      h2(page_header),
      form{
        method = "post",
        action = action,
        p{
          strings.title, br(), error_title, input{ type = "text",
            name = "title", value = params.title or params.section.title },
	    br(), br(),
          strings.description, br(), textarea{ name = "description",
	    rows = "5", cols = "40", params.description or
	    params.section.description }, br(), br(),
          strings.tag, br(), input{ type = "text", name = "tag",
	    value = params.tag or params.section.tag }, br(), br(),
          input{ type = "submit", value = button_text }
        }
      }, delete
    }
  end,
  edit_post = function (app, params)
    local error_title = ""
    if params.error_title then
      error_title = error_message(params.error_title) .. br()
    end
    local page_header, button_text
    if not params.post.id then
      page_header = strings.new_post
      button_text = strings.add
    else
      page_header = strings.edit_post
      button_text = strings.edit
    end
    local action
    local delete
    if params.post.id then
      action = app:link("/editpost/" .. params.post.id)
      delete = form{ method = "post", action = app:link("/deletepost/" ..
	params.post.id), input{ type = "submit", value = strings.delete } }
    else
      action = app:link("/editpost")
    end
    local sections = {}
    for _, section in pairs(params.sections) do
      sections[#sections + 1] = option{ value = section.id, 
	selected = (section.id == (tonumber(params.section_id) or
				   params.post.section_id)) or nil, 
	section.title }
    end
    sections = "<select name=\"section_id\">" .. table.concat(sections, "\n") ..
      "</select>"
    local comment_status = {}
    for status, text in pairs({ closed = strings.closed, 
			        moderated = strings.moderated,
				unmoderated = strings.unmoderated }) do
      comment_status[#comment_status + 1] = option{ value = status,
        selected = (status == (params.comment_status or 
			       params.post.comment_status)) or nil, text }
    end
    local comment_status = "<select name=\"comment_status\">" ..
      table.concat(comment_status, "\n") .. "</select>"
    return div{
      h2(page_header),
      form{
        method = "post",
        action = action,
        p{
          strings.section, br(), sections, br(), br(),
          strings.title, br(), error_title, input{ type = "text",
            name = "title", value = params.title or params.post.title },
	    br(), br(),
          strings.index_image, br(), error_title, input{ type = "text",
            name = "image", value = params.image or params.post.image },
	    br(), br(),
          strings.external_url, br(), input{ type = "text",
            name = "external_url", value = params.external_url or 
	      params.post.external_url },
	    br(), br(),
          strings.abstract, br(), textarea{ name = "abstract",
	    rows = "5", cols = "40", params.abstract or
	    params.post.abstract }, br(), br(),
          strings.body, br(), textarea{ name = "body",
	    rows = "15", cols = "80", params.body or
	    params.post.body }, br(), br(),
          strings.comment_status, br(), comment_status, br(), br(),
          strings.published_at, br(), input{ type = "text",
	    name = "published_at", value = params.published_at or
	      os.date("%d-%m-%Y %H:%M", params.post.published_at) }, br(), br(),
          input{ type = "checkbox", name = "published", value = "1",
            checked = params.published or params.post.published or nil },
	    strings.published, br(), br(),
          input{ type = "checkbox", name = "in_home", value = "1",
            checked = params.in_home or params.post.in_home or nil },
	    strings.in_home, br(), br(),
          input{ type = "submit", value = button_text }
        }
      }, delete
    }
  end,
  manage_comments = function (app, params)
    local for_mod = {}
    for _, comment in ipairs(params.for_mod) do
      for_mod[#for_mod + 1] = div{
	p{ id = comment.id, strong{ strings.comment_by, " ", 
	    comment:make_link(), " ",
	  strings.on_post, " ", a{ 
	    href = app:link("/post/" .. comment.post_id), comment.post_title },
	  " ", strings.on, " ", time(comment.created_at), ":" } },
	markdown(comment.body),
        p{ form{ action = app:link("/comment/" .. comment.id .. "/approve"),
	    method = "post", input{ type = "submit", value = strings.approve }
	    }, form{ action = app:link("/comment/" .. comment.id .. "/delete"),
	    method = "post", input{ type = "submit", value = strings.delete }
	    }
        },
      }
    end
    local approved = {}
    for _, comment in ipairs(params.approved) do
      approved[#approved + 1] = div{
	p{ id = comment.id, strong{ strings.comment_by, " ", 
	    comment:make_link(), " ",
	  strings.on_post, " ", a{ 
	    href = app:link("/post/" .. comment.post_id), comment.post_title },
	  " ", strings.on, " ", time(comment.created_at), ":" } },
	markdown(comment.body),
        p{ form{ action = app:link("/comment/" .. comment.id .. "/delete"),
	    method = "post", input{ type = "submit", value = strings.delete }
	    } },
      }
    end
    if #for_mod == 0 then for_mod = { p{ strings.no_comments } } end
    if #approved == 0 then approved = { p{ strings.no_comments } } end
    return div{
      h2(strings.waiting_moderation),
      table.concat(for_mod, "\n"),
      h2(strings.published),
      table.concat(approved, "\n")
    }
  end
}
