local _M = {}
function _M.setfenv(func, env)
  local i = 1
  while true do
    local name = debug.getupvalue(func, i)
    if name == "_ENV" then
      debug.upvaluejoin(func, i,(function()
        return env
      end), 1)
      break
    elseif not name then
      break
    end
    i = i + 1
  end
  return func
end

function _M.getfenv(func)
  local i = 1
  while true do
    local name, val = debug.getupvalue(func, i)
    if name == "_ENV" then
      return val
    elseif not name then
      break
    end
    i = i + 1
  end
end

return _M