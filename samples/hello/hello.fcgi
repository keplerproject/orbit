#!/usr/bin/env lua51

package.path = "/path/to/hello/?.lua;" .. package.path

require"wsapi.fastcgi"

require"hello"

wsapi.fastcgi.run(hello.run)

