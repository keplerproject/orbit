#!/usr/bin/env lua51

package.path = "/path/to/toycms/?.lua;" .. package.path

require"wsapi.cgi"

require"toycms"

wsapi.cgi.run(toycms.run)

