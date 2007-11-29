module("toycms", package.seeall)

plugins = {}

function plugins.date(app)
  return {
    today_day = tonumber(os.date("%d", os.time())),
    today_month_name = month_names[tonumber(os.date("%m", os.time()))],
    today_year = tonumber(os.date("%Y", os.time()))
  }
end

function plugins.archive(app)
  return {
    month_list = function (arg, has_block)
      arg = arg or {}
      if arg.include_tags then
        local sections = 
	  app.models.section:find_all("tag like ?", { arg.include_tags })
	local section_ids = {}
	for _, section in ipairs(sections) do
	  section_ids[#section_ids + 1] = section.id
        end
        local months = app.models.post:find_months(section_ids)
	local function do_list()
	  for _, month in ipairs(months) do
	    local env = app:new_template_env()
	    env.month = month.month
	    env.year = month.year
	    env.month_padded = string.format("%.2i", month.month)
	    env.month_name = month_names[month.month]
	    env.uri = app:link("/archive/" .. env.year .. "/" ..
			       env.month_padded)
	    cosmo.yield(env)
          end
        end
	if has_block then
	  do_list()
        else
          local template = app:load_template(arg.template or 
					     "section_list.html")
          return cosmo.fill("$do_list[[" .. template .. "]]",
            { do_list = do_list })
        end
      else
        return nil
      end
    end
  }
end

function plugins.section_list(app)
  return {
    section_list = function (arg, has_block)
      arg = arg or {}
      local template = arg.template
      if arg.include_tags then
        arg = { arg.include_tags }
        arg.condition = "tag like ?"
      end
      local function do_list()
        local sections = app.models.section:find_all(arg.condition, arg)
        for _, section in ipairs(sections) do
          app.input.section_id = section.id
          local env = app:new_section_env(section)
          cosmo.yield(env)
        end
      end
      if has_block then
        do_list()
      else
        local template = app:load_template(template or "section_list.html")
        return cosmo.fill("$do_list[[" .. template .. "]]",
          { do_list = do_list })
      end
    end
  }
end

local function get_posts(app, condition, args, count)
  return function ()
    local posts =
      app.models.post:find_all(condition, args)
    local cur_date
    for i, post in ipairs(posts) do
      if count and (i > count) then break end
      local env = app:new_post_env(post)
      env.if_new_date = cosmo.cond(cur_date ~= env.date_string, env)
      if cur_date ~= env.date_string then
	cur_date = env.date_string
      end
      env.if_first = cosmo.cond(i == 1, env)
      env.if_not_first = cosmo.cond(i ~= 1, env)
      env.if_last = cosmo.cond(i == #posts, env)
      env.if_not_post = cosmo.cond(app.input.post_id ~= post.id, env)
      cosmo.yield(env)
    end
  end
end

function plugins.home(app)
  return {
    headlines = function (arg, has_block)
      local do_list = get_posts(app, "in_home = ? and published = ?",
	    { order = "published_at desc", true, true })
      if has_block then
	do_list()
      else
        local template = app:load_template("home_short_info.html")
        return cosmo.fill("$do_list[[" .. template .. "]]",
          { do_list = do_list })
      end
    end
  }
end

function plugins.index_view(app)
  return {
    show_posts = function (arg, has_block)
      local section_ids = {}
      local template_file = (arg and arg.template) or "index_short_info.html"   
      if arg and arg.include_tags then
	local sections = app.models.section:find_by_tags{ arg.include_tags }
        for _, section in ipairs(sections) do
          section_ids[#section_ids + 1] = section.id
        end
      elseif app.input.section_id then
        section_ids[#section_ids + 1] = app.input.section_id
      end
      if #section_ids == 0 then return "" end
      local date_start, date_end
      if arg and arg.archive and app.input.month and app.input.year then
        date_start = os.time({ year = app.input.year, 
			    month = app.input.month, day = 1 })
        date_end = os.time({ year = app.input.year + 
			    math.floor(app.input.month / 12),
                            month = (app.input.month % 12) + 1,
                            day = 1 })
      end
      local do_list = get_posts(app, "published = ? and section_id = ? and " ..
			           "published_at >= ? and published_at <= ?",
              { order = "published_at desc", true, section_ids, date_start,
	        date_end },
              (arg and arg.count))
      if has_block then
        do_list()
      else
        local template = app:load_template(template_file)
        return cosmo.fill("$do_list[[" .. template .. "]]",
          { do_list = do_list })
      end
    end
  }
end
