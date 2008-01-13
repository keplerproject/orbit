#!/usr/bin/env wsapi

local orbit = require"orbit"
local cosmo = require"template.cosmo"

local songs = orbit.new()

function songs.index(web)
   local songlist = {
      "Sgt. Pepper's Lonely Hearts Club Band",
      "With a Little Help from My Friends",
      "Lucy in the Sky with Diamonds",
      "Getting Better",
      "Fixing a Hole",
      "She's Leaving Home",
      "Being for the Benefit of Mr. Kite!",
      "Within You Without You",
      "When I'm Sixty-Four",
      "Lovely Rita",
      "Good Morning Good Morning",
      "Sgt. Pepper's Lonely Hearts Club Band (Reprise)",
      "A Day in the Life"
   }
   return songs.render_index(songlist)
end

songs:dispatch_get(songs.index, "/")

function songs.layout(inner_html)
  return html{
    head{ title"Song List" },
    body{ inner_html }
  }
end

orbit.htmlify(songs, "layout")

function songs.render_index(songlist)
   local template = [[
	 <h1>Songs</h1>
	    <table>
	    $songs[=[<tr><td>$title</td></tr>]=]
	 </table>  
      ]]
   return cosmo.fill(template, {
			songs = function ()
				   for _, song in ipairs(songlist) do
				      cosmo.yield{ title = song }
				   end
				end
		     })
end

return songs.run
