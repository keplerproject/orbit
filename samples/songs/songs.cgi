#!/usr/bin/env lua

local lfs = require "lfs"

lfs.chdir("/home/mascarenhas/work/orbit/samples/songs")

local wscgi = require "wsapi.cgi"

local songs = require "songs"

wscgi.run(songs.run)

