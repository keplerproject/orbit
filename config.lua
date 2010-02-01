
theme = "wordpress"

blocks = {
  title = { "title", args = { "Test Website" } },
  javascript = { "javascript" },
  css = { "css", args = { "/styles/default.css" } },
  banner = { "banner", args = { title = "Test Website", tagline = "It is simple!" } },
  copyright = { "copyright", args = { "2010" } },
  about = { "about", args = { title = "About Website", text = "Lorem ipsum." } },
  links = { 
    "links", args = { title = "Useful Links", 
		      links = {
			{ "Lua", "http://www.lua.org" },
			{ "Kepler", "http://www.keplerproject.org" }
		      }
		    }
  },
  show_latest = { "show_latest", args = { count = 7 } },
  recent_links = { "show_latest", args = { title = "Recent Posts", count = 7 } },
  powered_by = { "about", args = { title = "Powered by", text = "Orbit and Kepler toolkit." } }
}
