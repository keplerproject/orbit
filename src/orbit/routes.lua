local setmetatable, type, ipairs, table, string = setmetatable, type, ipairs,
  table, string

local lpeg = require "lpeg"
local re = require "re"
local util = require "wsapi.util"

local _M = {}

local alpha = lpeg.R('AZ', 'az')
local number = lpeg.R('09')
local asterisk = lpeg.P('*')
local question_mark = lpeg.P('?')
local at_sign = lpeg.P('@')
local colon = lpeg.P(':')
local the_dot = lpeg.P('.')
local underscore = lpeg.P('_')
local forward_slash = lpeg.P('/')
local slash_or_dot = forward_slash + the_dot

local function cap_param(prefix, name, dot)
  local inner = (1 - lpeg.S('/' .. (dot or '')))^1
  local close = lpeg.P'/' + (dot or -1) + -1
  return {
    cap = lpeg.Carg(1) * slash_or_dot * lpeg.C(inner^1) *
      #close / function (params, item, delim)
        params[name] = util.url_decode(item)
      end,
    clean = slash_or_dot * inner^1 * #close,
    tag = "param",
    name = name,
    prefix = prefix
  }
end

local param_pre = lpeg.C(slash_or_dot) * colon * 
  peg.C((alpha + number + underscore)^1)

local param = (param_pre * #(forward_slash + -1) / cap_param) +
  (param_pre * #the_dot / function (prefix, name)
    return cap_param(prefix, name, ".")
  end)

local function cap_opt_param(prefix, name, dot)
  local inner = (1 - lpeg.S('/' .. (dot or '')))^1
  local close = lpeg.P('/') + lpeg.P(dot or -1) + -1
  return {
    cap = (lpeg.Carg(1) * slash_or_dot * lpeg.C(inner) *
      #close / function (params, item, delim)
        params[name] = util.url_decode(item)
      end)^-1,
    clean = (slash_or_dot * inner * #lpeg.C(close))^-1,
    tag = "opt",
    name = name,
    prefix = prefix
  }
end

local opt_param_pre = lpeg.C(slash_or_dot) * question_mark * colon *
  lpeg.C((alpha + number + underscore)^1) * question_mark

local opt_param = (opt_param_pre * #(forward_slash + -1) / cap_opt_param) +
  (opt_param_pre * #the_dot / function (prefix, name)
    return cap_opt_param(prefix, name, ".")
  end)

local splat = lpeg.P(lpeg.C(forward_slash + the_dot) * asterisk *
  #(forward_slash + the_dot + -1)) / function (prefix)
    return {
      cap = "*",
      tag = "splat",
      prefix = prefix
    }
  end

local rest = lpeg.C((1 - param - opt_param - splat)^1)

local function fold_captures(cap, acc)
  if type(cap) == "string" then
    return {
      cap = lpeg.P(cap) * acc.cap,
      clean = lpeg.P(cap) * acc.clean
    }
  end
  -- if we have a star match (match everything)
  if cap.cap == "*" then
    return {
      cap = (lpeg.Carg(1) * (cap.prefix *
        lpeg.C((1 - acc.clean)^0))^-1 / function (params, splat)
          params.splat = params.splat or {}
          if splat and splat ~= "" then
            params.splat[#params.splat+1] = util.url_decode(splat)
          end
        end) * acc.cap,
      clean = (cap.prefix * (1 - acc.clean)^0)^-1 * acc.clean
    }
  end
  return {
    cap = cap.cap * acc.cap,
    clean = cap.clean * acc.clean
  }
end

local function fold_parts(parts, cap)
  if type(cap) == "string" then -- if the capture is a string
    parts[#parts+1] = {
      tag = "text",
      text = cap
    }
  else                          -- it must be a table capture
    parts[#parts+1] = {
      tag = cap.tag,
      prefix = cap.prefix,
      name = cap.name
    }
  end
  return parts
end

-- the right part (a bottom to top loop)
local function fold_right(t, f, acc)
  for i = #t, 1, -1 do
    acc = f(t[i], acc)
  end
  return acc
end

-- the left part (a top to bottom loop)
local function fold_left(t, f, acc)
  for i = 1, #t do
    acc = f(acc, t[i])
  end
  return acc
end

local route = lpeg.Ct((param + opt_param + splat + rest)^0 * -1) / function (caps)
  local forward_slash_at_end = lpeg.P('/')^-1 * -1
  return fold_right(caps, fold_captures, {
    cap = forward_slash_at_end,
    clean = forward_slash_at_end
  }), fold_left(caps, fold_parts, {})
end

local function build(parts, params)
  local res, i = {}, 1
  params = params or {}
  params.splat = params.splat or {}
  for _, part in ipairs(parts) do
    if part.tag == 'param' then
      if not params[part.name] then
        error('route parameter ' .. part.name .. ' does not exist')
      end
      local s = string.gsub (params[part.name], '([^%.@]+)', function (s)
        return util.url_encode(s)
      end)
      res[#res+1] = part.prefix .. s
    elseif part.tag == "splat" then
      local s = string.gsub (params.splat[i] or '', '([^/%.@]+)', function (s)
        return util.url_encode(s)
      end)
      res[#res+1] = part.prefix .. s
      i = i + 1
    elseif part.tag == "opt" then
      if params and params[part.name] then
        local s = string.gsub (params[part.name], '([^%.@]+)', function (s)
          return util.url_encode(s)
        end)
        res[#res+1] = part.prefix .. s
      end
    else
      res[#res+1] = part.text
    end
  end
  if #res > 0 then
    return table.concat(res)
  end
  return '/'
end

function _M.R(path)
  local p, b = route:match(path)
  return setmetatable(
    {
      parser = p.cap,
      parts = b
    },
    {
      __index = {
        match = function (t, s)
          local params = {}
          if t.parser:match(s, 1, params) then
            return params
          end
          return nil
        end,
        build = function (t, params)
          return build(t.parts, params)
        end
      }
    }
  )
end

return setmetatable(_M, {
  __call = function (_, path)
    return _M.R(path)
  end
})