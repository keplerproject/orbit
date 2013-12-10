#!/usr/bin/env lua51

local lfs = require "lfs"

lfs.chdir("/path/to/toycms")

local wsfcgi = require "wsapi.fastcgi"

local toycms = require"toycms"

wsfcgi.run(toycms.run)
