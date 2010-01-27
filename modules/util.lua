
local util = {}

function util.loadin(file, env)
  env = env or {}
  local f, err = loadfile(file)
  if not f then
    return nil, err
  else
    setfenv(f, env)
    local ok, err = pcall(f)
    if ok then
      return env
    else
      return nil, err
    end
  end
end

function util.readfile(filename)
  local file, err = io.open(filename, "rb")
  if file then
    local str = file:read("*a")
    file:close()
    return str
  else
    return nil, err
  end
end

return util
