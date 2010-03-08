
require "lpeg"
require "re"
require "wsapi.util"

module("orbit.routes", package.seeall)

local function foldr(t, f, acc)
   for i = #t, 1, -1 do
      acc = f(t[i], acc)
   end
   return acc
end

local function foldl(t, f, acc)
   for i = 1, #t do
      acc = f(acc, t[i])
   end
   return acc
end

param = re.compile[[ {[/%.]} ':' {[%w_]+} &('/' / {'.'} / !.) ]] / 
             function (prefix, name, dot)
		local extra = { inner = (lpeg.P(1) - lpeg.S("/" .. (dot or "")))^1,
				close = lpeg.P"/" + lpeg.P(dot or -1) + lpeg.P(-1) }
		return { cap = lpeg.Carg(1) * re.compile([[ [/%.] {%inner+} &(%close) ]], extra) / 
		                   function (params, item, delim)
				      params[name] = wsapi.util.url_decode(item)
				   end,
				clean = re.compile([[ [/%.] %inner &(%close) ]], extra),
			      tag = "param", name = name, prefix = prefix }
	     end

opt_param = re.compile[[ {[/%.]} '?:' {[%w_]+} '?' &('/' / {'.'} / !.) ]] / 
             function (prefix, name, dot)
		local extra = { inner = (lpeg.P(1) - lpeg.S("/" .. (dot or "")))^1,
				close = lpeg.P"/" + lpeg.P(dot or -1) + lpeg.P(-1) }
		return { cap = (lpeg.Carg(1) * re.compile([[ [/%.] {%inner+} &(%close) ]], extra) / 
		                   function (params, item, delim)
				      params[name] = wsapi.util.url_decode(item)
				   end)^-1,
				clean = re.compile([[ [/%.] %inner &(%close) ]], extra)^-1,
			      tag = "opt", name = name, prefix = prefix }
	     end

splat = re.compile[[ {[/%.]} {'*'} &('/' / '.' / !.) ]] /
              function (prefix)
		return prefix, { cap = "*", tag = "splat", prefix = prefix }
	      end

rest = lpeg.C((lpeg.P(1) - param - opt_param - splat)^1)

fold_caps = function (cap, acc)
	       if type(cap) == "string" then
		  return { cap = lpeg.P(cap) * acc.cap, clean = lpeg.P(cap) * acc.clean }
	       elseif cap.cap == "*" then
		  return { cap = (lpeg.Carg(1) * lpeg.C((lpeg.P(1) - acc.clean)^1) / 
                                      function (params, splat)
					 if not params.splat then params.splat = {} end
					 params.splat[#params.splat+1] = wsapi.util.url_decode(splat)
				      end) * acc.cap,
			   clean = (lpeg.P(1) - acc.clean)^1 * acc.clean }
	       else
		  return { cap = cap.cap * acc.cap, clean = cap.clean * acc.clean }
	       end
	    end

fold_parts = function (parts, cap)
	       if type(cap) == "string" then
		 parts[#parts+1] = { tag = "text", text = cap }
	       else
		 parts[#parts+1] = { tag = cap.tag, prefix = cap.prefix, name = cap.name }
	       end
	       return parts
	     end

route = lpeg.Ct((param + opt_param + splat + rest)^1 * lpeg.P(-1)) / 
           function (caps)
	      return foldr(caps, fold_caps, { cap = lpeg.P("/")^-1 * lpeg.P(-1), clean = lpeg.P("/")^-1 * lpeg.P(-1) }),
	             foldl(caps, fold_parts, {})
	   end

local function build(parts, params)
  local res = {}
  local i = 1
  for _, part in ipairs(parts) do
    if part.tag == "param" then
      local s = string.gsub (params[part.name], "([^%.@]+)",
			     function (s) return wsapi.util.url_encode(s) end)
      res[#res+1] = part.prefix .. s
    elseif part.tag == "splat" then
      local s = string.gsub (params.splat[i], "([^/%.@]+)",
			     function (s) return wsapi.util.url_encode(s) end)
      res[#res+1] = s
      i = i + 1
    elseif part.tag == "opt" then
      if params and params[part.name] then
	local s = string.gsub (params[part.name], "([^%.@]+)",
			       function (s) return wsapi.util.url_encode(s) end)
	res[#res+1] = part.prefix .. s
      end
    else
      res[#res+1] = part.text
    end
  end
  if #res > 0 then return table.concat(res) else return "/" end
end

function R(path)
   local p, b = route:match(path)
   return setmetatable({ parser = p.cap, parts = b },
		       { __index = { 
			   match = function (t, s)
				     local params = {}
				     if t.parser:match(s, 1, params) then
				       return params
				     else
				       return nil
				     end
				   end,
			   build = function (t, params)
				     return build(t.parts, params)
				   end
		       } })
end

