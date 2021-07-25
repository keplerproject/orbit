-----------------------------------------------------------------------------
-- Xavante Orbit pages handler
--
-- Author: Fabio Mascarenhas
--
-----------------------------------------------------------------------------

local wsapi = require "wsapi"
local wsxav = require "wsapi.xavante"
local wscom = require "wsapi.common"

-------------------------------------------------------------------------------
-- Returns the Orbit Pages handler
-------------------------------------------------------------------------------
local function makeHandler (diskpath, params)
  params = setmetatable({ modname = params.modname or "orbit.pages" }, { __index = params or {} })
  local op_loader = wscom.make_isolated_launcher(params)
  return wsxav.makeHandler(op_loader, nil, diskpath)
end

return { makeHandler = makeHandler }