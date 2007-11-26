#!/usr/bin/env lua51

package.path = "/path/to/hello/?.lua;" .. package.path

require"wsapi.cgi"

require"hello"

wsapi.cgi.run(hello.run)

