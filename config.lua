
theme = "wordpress"

home_page = "/home"

blocks = {
  title = { "title", args = { "Test Website" } },
  javascript = { "javascript", args = { 
	 "http://ajax.googleapis.com/ajax/libs/jquery/1.4.1/jquery.min.js",
	 "http://jquery-json.googlecode.com/files/jquery.json-2.2.min.js",
	 "/js/form_support.js",
	} },
  css = { "css", args = { "/styles/default.css" } },
  banner = { "banner", args = { title = "Test Website", tagline = "It is simple!" } },
  copyright = { "copyright", args = { "2010" } },
  about = { "generic", args = { title = "About Website", text = "Lorem ipsum." } },
  links = { 
    "links", args = { title = "Useful Links", 
		      links = {
			{ "Lua", "http://www.lua.org" },
			{ "Kepler", "http://www.keplerproject.org" }
		      }
		    }
  },
  show_latest = { "show_latest_body", args = { count = 7 } },
  recent_links = { "show_latest", args = { title = "Recent Posts", count = 7 } },
  powered_by = { "generic", args = { title = "Powered by", text = "Orbit and Kepler toolkit." } },
  post = { "node_info" },
  poll = { "latest_poll" },
  poll_result = { "poll_total" }
}

database = {
  driver = "mysql",
  connection = { "publique-devel", "root", "rfc8000" }
}

plugins = {
  "nodes.lua",
  "poll.lua"
}

