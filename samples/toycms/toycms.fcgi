#!/usr/bin/env lua51

package.path = "/path/to/toycms/?.lua;" .. package.path

require"wsapi.fastcgi"

require"toycms"

wsapi.fastcgi.run(toycms.run)
