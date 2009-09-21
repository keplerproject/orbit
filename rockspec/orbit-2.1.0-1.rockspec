package = "Orbit"

version = "2.1.0-1"

source = {
  url = "http://luaforge.net/frs/download.php/3975/orbit-2.1.0.tar.gz",
}

description = {
  summary = "MVC for Lua Web Development",
  detailed = [[
     Orbit is a library for developing web applications according to
     the Model-View-Controller paradigm in Lua.
  ]],
  license = "MIT/X11",
  homepage = "http://www.keplerproject.org/orbit"
}

dependencies = { 'wsapi >= 1.1', 'luafilesystem >= 1.4.2', 'cosmo >= 9.09.22' }

build = {
   type = "module",
   modules = {
     orbit = "src/orbit.lua",
     ["orbit.model"] = "src/model.lua",
     ["orbit.pages"] = "src/pages.lua",
     ["orbit.cache"] = "src/cache.lua",
     ["orbit.ophandler"] = "src/ophandler.lua",
   },
   install = { bin = { "src/orbit" } },
   copy_directories = { "doc", "samples", "test" }
}
