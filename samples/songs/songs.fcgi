#!/usr/bin/env lua

local lfs = require "lfs"

lfs.chdir("/home/mascarenhas/work/orbit/samples/songs")

local wsfcgi = require "wsapi.fastcgi"

local sontgs = require "songs"

wsfcgi.run(songs.run)

