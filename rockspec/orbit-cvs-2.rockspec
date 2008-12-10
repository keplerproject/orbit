package = "Orbit"

version = "cvs-2"

description = {
  summary = "MVC for Lua Web Development",
  detailed = [[
     Orbit is a library for developing web applications according to
     the Model-View-Controller paradigm in Lua.
  ]],
  license = "MIT/X11",
  homepage = "http://www.keplerproject.org/orbit"
}

dependencies = { 'wsapi cvs', 'luafilesystem cvs', 'cosmo current' }

source = {
  url = "cvs://:pserver:anonymous@cvs.luaforge.net:/cvsroot/orbit",
  cvs_tag = "HEAD"
}

build = {
   type = "module",
   modules = {
     orbit = "src/orbit.lua",
     ["orbit.model"] = "src/model.lua",
     ["orbit.pages"] = "src/pages.lua",
     ["orbit.cache"] = "src/cache.lua",
     ["orbit.ophandler"] = "src/ophandler.lua",
   },
   copy_directories = { "doc", "samples", "test" }
}
