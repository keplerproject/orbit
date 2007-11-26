#!/usr/bin/env lua51

package.path = "/path/to/blog/?.lua;" .. package.path

require"wsapi.cgi"

require"blog"

wsapi.cgi.run(blog.run)

