module("orbit.model", package.seeall)

model_methods = {}

dao_methods = {}

local convert = {}

function convert.integer(v)
  return tonumber(v)
end

function convert.varchar(v)
  return tostring(v)
end

function convert.text(v)
  return tostring(v)
end

function convert.boolean(v)
  return v == "t"
end

function convert.datetime(v)
  local year, month, day, hour, min, sec = 
    string.match(v, "(%d+)%-(%d+)%-(%d+) (%d+):(%d+):(%d+)")
  return os.time({ year = tonumber(year), month = tonumber(month),
		   day = tonumber(day), hour = tonumber(hour),
		   min = tonumber(min), sec = tonumber(sec) })
end

local function convert_types(row, meta)
  for k, v in pairs(row) do
    if meta[k] then
      row[k] = convert[meta[k].type](v)
    end
  end
end

local escape = {}

function escape.integer(v)
  return tostring(v)
end

function escape.varchar(v)
  return "'" .. string.gsub(v, "'", "''") .. "'"
end

function escape.text(v)
  return "'" .. string.gsub(v, "'", "''") .. "'"
end

function escape.datetime(v)
  return "'" .. os.date("%Y-%m-%d %H:%M:%S", v) .. "'"
end

function escape.boolean(v)
  if v then
    return "'t'"
  else
    return "'f'"
  end
end

local function escape_values(row)
  local row_escaped = {}
  for i, m in ipairs(row.meta) do
    if row[m.name] == nil then
      row_escaped[m.name] = "NULL" 
    else
      row_escaped[m.name] = escape[m.type](row[m.name])
    end
  end
  return row_escaped
end

local function fetch_row(dao, sql)
  local cursor, err = dao.model.conn:execute(sql)
  if not cursor then error(err) end
  local row = cursor:fetch({}, "a")
  cursor:close()
  if row then
    convert_types(row, dao.meta)
    setmetatable(row, { __index = dao })
  end
  return row
end

local function fetch_rows(dao, sql, count)
  local rows = {}
  local cursor, err = dao.model.conn:execute(sql)
  if not cursor then error(err) end
  local row, fetched = cursor:fetch({}, "a"), 1
  while row and (not count or fetched <= count) do
    convert_types(row, dao.meta)
    setmetatable(row, { __index = dao })
    rows[#rows + 1] = row
    row, fetched = cursor:fetch({}, "a"), fetched + 1
  end
  cursor:close()
  return rows
end

local function parse_condition(dao, condition, args)
  condition = string.gsub(condition, "_and_", "|")
  local pairs = {}
  for field in string.gmatch(condition, "[%w_]+") do
    local i = #pairs + 1
    local value
    if args[i] == nil then
      pairs[i] = field .. " is null"
    elseif type(args[i]) == "table" then
      local values = {}
      for _, value in ipairs(args[i]) do
	values[#values + 1] = escape[dao.meta[field].type](value)
      end
      pairs[i] = field .. " IN (" .. table.concat(values,", ") .. ")"
    else
      value = escape[dao.meta[field].type](args[i])
      pairs[i] = field .. " = " .. value
    end
  end
  return pairs
end

local function build_inject(inject, dao)
  local fields = {}
  for i, field in ipairs(dao.meta) do
    fields[i] = dao.table_name .. "." .. field.name .. " as " .. field.name
  end
  local inject_fields = {}
  local model = inject.model
  for _, field in ipairs(inject.fields) do
    inject_fields[model.name .. "_" .. field] =
      model.meta[field]
    fields[#fields + 1] = model.table_name .. "." .. field .. " as " ..
      model.name .. "_" .. field
  end
  setmetatable(dao.meta, { __index = inject_fields })
  return table.concat(fields, ", "), dao.table_name .. ", " .. 
    model.table_name,  model.name .. "_id = " .. model.table_name .. ".id"
end

local function build_query_by(dao, condition, args)
  local pairs = parse_condition(dao, condition, args)
  local order = ""
  local field_list
  local table_list
  if args.order then order = " order by " .. args.order end
  if args.inject then
    field_list, table_list, pairs[#pairs + 1] = build_inject(args.inject,
      dao)
  else
    field_list = "*"
    table_list = dao.table_name
  end
  local sql = "select " .. field_list .. " from " .. table_list ..
    " where " .. table.concat(pairs, " and ") .. order
  return sql
end

local function find_by(dao, condition, args)
  return fetch_row(dao, build_query_by(dao, condition, args))
end

local function find_all_by(dao, condition, args)
  return fetch_rows(dao, build_query_by(dao, condition, args), args.count)
end

local function dao_index(dao, name)
  local m = dao_methods[name]
  if m then
    return m
  else
    local match = string.match(name, "^find_by_(.+)$")
    if match then
      return function (dao, args) return find_by(dao, match, args) end
    end
    local match = string.match(name, "^find_all_by_(.+)$")
    if match then
      return function (dao, args) return find_all_by(dao, match, args) end
    end
    return nil
  end
end

function model_methods:new(name, dao)
  dao = dao or {}
  dao.model, dao.name, dao.table_name, dao.meta = self, name, 
    self.table_prefix .. name, {}
  setmetatable(dao, { __index = dao_index })
  local sql = "select * from " .. dao.table_name
  local cursor, err = self.conn:execute(sql)
  if not cursor then error(err) end
  local names, types = cursor:getcolnames(), cursor:getcoltypes()
  cursor:close()
  for i = 1, #names do
    local colinfo = { name = names[i],
    type = string.lower(string.match(types[i], "(%a+)")) }
    dao.meta[i] = colinfo
    dao.meta[colinfo.name] = colinfo
  end
  return dao
end

function new(table_prefix, conn)
  local app_model = { table_prefix = table_prefix, conn = conn, models = {} }
  setmetatable(app_model, { __index = model_methods })
  return app_model
end

function dao_methods.find(dao, id, inject)
  if not type(id) == "number" then
    error("find error: id must be a number")
  end
  local sql = "select * from " .. dao.table_name ..
    " where id=" .. id
  return fetch_row(dao, sql)
end

local function build_query(dao, condition, args)
  local i = 0
  args = args or {}
  condition = condition or ""
  if type(condition) == "table" then
    args = condition
    condition = ""
  end
  if condition ~= "" then
    condition = " where " ..
      string.gsub(condition, "([%w_]+)%s*([%a<>=]+)%s*%?",
		  function (field, op)
		    i = i + 1
		    if not args[i] then
		      return "id=id"
		    elseif type(args[i]) == "table" then
		      local values = {}
		      for j, value in ipairs(args[i]) do
			values[#values + 1] = field .. " " .. op .. " " ..
		          escape[dao.meta[field].type](value)
                      end
		      return "(" .. table.concat(values, " or ") .. ")"
                    else
		      return field .. " " .. op .. " " ..
		        escape[dao.meta[field].type](args[i])
                    end
		  end)
  end
  local order = ""
  if args.order then order = " order by " .. args.order end
  local field_list
  local table_list
  if args.inject then
    local inject_condition
    field_list, table_list, inject_condition = build_inject(args.inject,
      dao)
    if condition == "" then
      condition = " where " .. inject_condition
    else
      condition = condition .. " and " .. inject_condition
    end
  else
    field_list = "*"
    table_list = dao.table_name
  end
  local sql = "select " .. field_list .. " from " .. table_list .. 
    condition .. order
  return sql
end

function dao_methods.find_first(dao, condition, args)
  return fetch_row(dao, build_query(dao.condition, args))
end

function dao_methods.find_all(dao, condition, args)
  return fetch_rows(dao, build_query(dao, condition, args), 
		    (args and args.count) or (condition and condition.count))
end

function dao_methods.new(dao)
  local row = {}
  setmetatable(row, { __index = dao })
  return row
end

local function update(row)
  local row_escaped = escape_values(row)
  local updates = {}
  if row.meta["updated_at"] then
    local now = os.time()
    row.updated_at = now
    row_escaped.updated_at = escape.datetime(now)
  end
  for k, v in pairs(row_escaped) do
    table.insert(updates, k .. "=" .. v)
  end
  local sql = "update " .. row.table_name .. " set " ..
    table.concat(updates, ", ") .. " where id = " .. row.id
  local ok, err = row.model.conn:execute(sql)
  if not ok then error(err) end
end

local function insert(row)
  local row_escaped = escape_values(row)
  local now = os.time()
  if row.meta["created_at"] then
    row.created_at = now
    row_escaped.created_at = escape.datetime(now)
  end
  if row.meta["updated_at"] then
    row.updated_at = now
    row_escaped.updated_at = escape.datetime(now)
  end
  local columns, values = {}, {}
  for k, v in pairs(row_escaped) do
    table.insert(columns, k)
    table.insert(values, v)
  end
  local sql = "insert into " .. row.table_name ..
    " (" .. table.concat(columns, ", ") .. ") values (" ..
    table.concat(values, ", ") .. ")"
  local ok, err = row.model.conn:execute(sql)
  if ok then row.id = row.model.conn:getlastautoid() else error(err) end
end

function dao_methods.save(row)
  if row.id then
    update(row)
  else
    insert(row)
  end
end

function dao_methods.delete(row)
  if row.id then
    local sql = "delete from " .. row.table_name .. " where id = " .. row.id
    local ok, err = row.model.conn:execute(sql)    
    if ok then row.id = nil else error(err) end
  end
end