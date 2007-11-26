#!/usr/bin/env lua51

package.path = "/path/to/blog/?.lua;" .. package.path

require"wsapi.fastcgi"

require"blog"

wsapi.fastcgi.run(blog.run)
