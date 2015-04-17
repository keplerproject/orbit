package = "Orbit"

version = "2.2.2-1"

description = {
  summary = "MVC for Lua Web Development",
  detailed = [[
     Orbit is a library for developing web applications according to
     the Model-View-Controller paradigm in Lua.
  ]],
  license = "MIT/X11",
  homepage = "http://www.keplerproject.org/orbit"
}

dependencies = {
  'luafilesystem >= 1.6.2',
  'lpeg >= 0.12',
  'wsapi-xavante >= 1.6',
  'cosmo >= 13.01.30',
  'lua >= 5.1, < 5.2',
}

source = {
  url = "git://github.com/keplerproject/orbit.git",
  tag = "v2.2.2",
}

build = {
   type = "builtin",
   modules = {
     orbit = "src/orbit.lua",
     ["orbit.model"] = "src/orbit/model.lua",
     ["orbit.pages"] = "src/orbit/pages.lua",
     ["orbit.cache"] = "src/orbit/cache.lua",
     ["orbit.ophandler"] = "src/orbit/ophandler.lua",
     ["orbit.routes"] = "src/orbit/routes.lua",
   },
   install = { bin = { "src/launchers/orbit", "src/launchers/op.cgi", "src/launchers/op.fcgi" } },
   copy_directories = { "doc", "samples", "test" }
}

