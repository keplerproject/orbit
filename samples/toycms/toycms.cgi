#!/usr/bin/env lua51

local lfs = require "lfs"

lfs.chdir("/path/to/toycms")

local wscgi = require "wsapi.cgi"

local toycms = require "toycms"

wscgi.run(toycms.run)

