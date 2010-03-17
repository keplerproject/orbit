
local mk = require "mk"
local util = require "mk.util"
local request = require "wsapi.request"
local response = require "wsapi.response"

local _M = {}

_M._NAME = "orbit"
_M._VERSION = "3.0"
_M._COPYRIGHT = "Copyright (C) 2007-2009 Kepler Project, Copyright (C) 2010 Fabio Mascarenhas"
_M._DESCRIPTION = "MVC Web Development for the Kepler platform"

_M.methods = {}
_M.methods.__index = _M.methods

function _M.new(app)
  local mk_app = mk.new(app)
  for k, v in pairs(_M.methods) do
    mk_app[k] = v
  end
  mk_app.mapper = { default = true }
  return mk_app
end

function _M.methods:htmlify(...)
  local patterns = { ... }
  for _, patt in ipairs(patterns) do
    if type(patt) == "function" then
      util.htmlify(patt)
    else
      for name, func in pairs(self) do
	if string.match(name, "^" .. patt .. "$") and type(func) == "function" then
	  htmlify_func(func)
	end
      end
    end
  end
end

function _M.methods:model(...)
  if self.mapper.default then
    if not orbit.model then
      require "orbit.model"
    end
    local mapper = orbit.model.new()
    mapper.conn, mapper.driver, mapper.logging, mapper.schema = 
      self.mapper.conn, self.mapper.driver or orbit.model.drivers.sqlite3, 
      self.mapper.logging, self.mapper.schema
    self.mapper = mapper
  end
  return self.mapper:new(...)
end

function _M.methods:page(req, res, name, env)
  local pages = require "orbit.pages"
  local filename
  if name:sub(1, 1) == "/" then
    filename = req.doc_root .. name
  else
    filename = req.app_path .. "/" .. name
  end
  local template = pages.load(filename)
  if template then
    return pages.fill(req, res, template, env)
  end
end

function _M.methods:page_inline(req, res, contents, env)
  local pages = require "orbit.pages"
  local template = pages.load(nil, contents)
  if template then
    return pages.fill(req, res, template, env)
  end
end

return _M
