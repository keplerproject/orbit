
module("cosmo", package.seeall)


local StringBuffer = {

   content = {},
   new = function (self) 
      o = {content={}}
      setmetatable(o, self)
      self.__index = self
      return o  
   end,

   add = function (self, text) 
      self.content[#self.content + 1] = text
   end,

   addf = function (self, template, ...) 
      self:add(string.format(template, ...))
   end,

   to_string = function (self) 
      output = ""
      for i, v in ipairs(self.content) do
	 output = output .. v
      end
      return output
   end,
}


function max_equals(text) 
   local max = ""
   string.gsub(text, "%[(=*)%[", 
	       function(match) 
		  if max:len() < match:len() then
		     max = match
		  end
	       end
	    )
   return max
end


Cosmo = {

   expand = function (self, text, tab, lazy)
      if not text then return "" end

      local templates = {}

      text = string.gsub(text, "$([%w_]+)(%b{})%[(=*)%[(.-)%]%3%]",
                         function(fname, arg, eqs, template)
			   templates[#templates + 1] = { fname, template, arg }
			   return "$!" .. #templates
                         end)

      text = string.gsub(text, "$([%w_]+)%[(=*)%[(.-)%]%2%]",
			 function(fname, eqs, template) 
			   templates[#templates + 1] = { fname, template }
			   return "$!" .. #templates
                         end)

      text = string.gsub(text, "$([%w_]+)(%b{})", 
			 function(fname, arg) 
			    local s = tab[fname]
			    if not s then
			       if lazy then
				  return ""
			       else
				  return "$"..fname
			       end
			    elseif type(s) == "function" then
			       return tostring(s(loadstring("return " .. arg)()))
			    else
			       return tostring(s)
			    end
			 end)

      text = string.gsub(text, "$([%w_]+)", 
			 function(n) 
			    local s = tab[n]
			    if not s then
			       if lazy then
				  return ""
			       else
				  return "$"..n
			       end
			    elseif type(s) == "function" then
			       return tostring(s())
			    else
			       return tostring(s)
			    end
			 end)

      text = string.gsub(text, "$!(%d+)",
                         function(n_template)
			    local fname, template, arg = 
			      unpack(templates[tonumber(n_template)])
			    local iterator = tab[fname]
			    if not (type(iterator) == "function")  then
			       error(string.format(
                                     "Cosmo: %s not a function but %s",
				     fname, type(iterator)))		   
			    end
			    if iterator then
			       return self:expand_items(template, 
							iterator, 
							fname,
						        arg)
			    else
			       if lazy then
				  return ""
			       else
				  return "$"..fname..(arg or "").."["..eqs.."]"
				     ..template
				     .."["..eqs.."]"
			       end
			    end
                         end)
	
      return text
   end,

   expand_items = function (self, template, fn, fn_name, arg)
      local buffer = StringBuffer:new()
      local co = coroutine.create(fn)
      if arg then arg = loadstring("return " .. arg)() end
      while true do
	 local status, value = coroutine.resume(co, arg, true)
	 if status then
	    if value then
	       buffer:add(self:expand(template, value))
	    else 
	       break
	    end
	 else
	    error("Cosmo: the iterator for " ..  fn_name 
		  .. " failed: " .. value)
	 end
      end
      return buffer:to_string()
   end,

   expand_list = function (self, template, array, tabfn)
      local buffer = StringBuffer:new()
      for i, tab in unpack(self:fpairs(array, tabfn)) do
	 if tab then
	    buffer:add(self:expand(template, tab))
	 end
      end
      return buffer:to_string()
   end
}


yield = coroutine.yield

cond = function(condition, tab)
	  return function()
		    if condition then
		       yield(tab)
		    end
		 end
       end


function test_iterator(f)
   co = coroutine.create(f)
   while true do
      status, value = coroutine.resume(co, nil, true)
      print(status, value)
      if not (status and value) then break end
   end
end

lazy_fill = function(template, tab) 
   return Cosmo:expand(template, tab, true) 
end

fill = function(template, tab) 
   return Cosmo:expand(template, tab) 
end
