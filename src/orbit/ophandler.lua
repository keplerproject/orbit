-----------------------------------------------------------------------------
-- Xavante Orbit pages handler
--
-- Author: Fabio Mascarenhas
--
-----------------------------------------------------------------------------

local   wsapi = require ("wsapi")
wsapi.xavante = require "wsapi.xavante"
wsapi.common  = require "wsapi.common"

module ("orbit.ophandler", package.seeall)

-------------------------------------------------------------------------------
-- Returns the Orbit Pages handler
-------------------------------------------------------------------------------
function makeHandler (diskpath, params)
   params = setmetatable({ modname = params.modname or "orbit.pages" }, { __index = params or {} })
   local op_loader = wsapi.common.make_isolated_launcher(params)
   return wsapi.xavante.makeHandler(op_loader, nil, diskpath)
end
