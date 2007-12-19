require"orbit"
require"cosmo"

module("songs", package.seeall, orbit.app)

songs:add_controllers{
  index = { "/",
    get = function(self)
	    local songs = {
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
            self:render("index", songs)
          end
  }
}

local cache

songs:add_views{
  layout = function (self)
             return html{
                       head{ title"Song List" },
                       body{ view() }
                    }
           end,
--[[  index = function (self, songs)
	    local tr_songs = {}
            for _, song in ipairs(songs) do
              table.insert(tr_songs, tr(td(song)))
            end
	    return h1"Songs" .. H"table"{ table.concat(tr_songs, "\n") }
          end ]]
      index = function (self, songs)
		local template = [[
		    <h1>Songs</h1>
		    <table>
		      $songs[=[<tr><td>$title</td></tr>]=]
		    </table>  
		]]
	        return cosmo.fill(template, {
				    songs = function ()
					      for _, song in ipairs(songs) do
						cosmo.yield{ title = song }
					      end
					    end
				  })
	      end
}

