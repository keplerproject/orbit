
local orbit = require "orbit"
local lfs = require "lfs"
local package = package
local require = require
local error = error
local pairs = pairs
local ipairs = ipairs
local print = print

module("publique", orbit.new)

package.path = real_path .. "/?.lua;" .. package.path

local util = require "modules.util"

blocks = { protos = require("modules.blocks"), instances = {} }
config = util.loadin(real_path .. "/config.lua")
if not config then
  error("cannot find config.lua in " .. real_path)
end

local themes = require "modules.themes"

theme = themes.new(config.theme, real_path .. "/themes")
if not theme then
  error("theme " .. config.theme .. " not found")
end

local core = require "modules.core"

for name, proto in pairs(config.blocks) do
  blocks.instances[name] = blocks.protos[proto[1]](proto.args, proto.template)
end

post = {
  find_latest = function ()
    return {
      { id = 1, nice_id = "/post/foo", title = "Foo" },
      { id = 2, type = "post", title = "Bar" },
      { id = 3, nice_id = "/post/bar-blaz", title = "Bar Blaz" }
    }
  end
}

return _M.run
