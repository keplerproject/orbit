-----------------------------------------------------------------------------
-- Xavante Orbit pages handler
--
-- Author: Fabio Mascarenhas
--
-----------------------------------------------------------------------------

require "wsapi.xavante"
require "wsapi.common"

module ("orbit.ophandler", package.seeall)

local function op_loader(wsapi_env)
  wsapi.common.normalize_paths(wsapi_env)
  local app = wsapi.common.load_isolated_launcher(wsapi_env.PATH_TRANSLATED, "orbit.pages")
  return app(wsapi_env)
end 

-------------------------------------------------------------------------------
-- Returns the CGILua handler
-------------------------------------------------------------------------------
function makeHandler (diskpath)
   return wsapi.xavante.makeHandler(op_loader, nil, diskpath)
end
