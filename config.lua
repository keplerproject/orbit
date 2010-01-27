
theme = "default"

blocks = {
  title = { "title", args = { "My Website" } },
  javascript = { "javascript" },
  css = { "css", args = { "/styles/default.css" } },
  banner = { "banner", args = { title = "My Website", tagline = "It is simple!" } },
  copyright = { "copyright", args = { "2009" } },
  about = { "about", args = { title = "About Website", text = "Lorem ipsum." } },
  links = { 
    "links", args = { title = "Useful Links", 
		      links = {
			{ "Lua", "http://www.lua.org" },
			{ "Kepler", "http://www.keplerproject.org" }
		      }
		    }
  },
  latest_posts = { "latest_posts", args = { count = 7 } }
}
