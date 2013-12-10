#! /usr/bin lua
-- Tests the examples from the Orbit reference
local orbit = require "orbit"
local luasql = require "luasql.sqlite3"
module("test_model", package.seeall, orbit.new)

mapper.conn = luasql.sqlite3():connect("books.db")
mapper.driver = "sqlite3"; mapper.table_prefix = ""
mapper.logging = false
local books = test_model:model "books"

local res = {}
local count = books:find_all("", { fields = {"count(*)" } })[1]["count(*)"]
print("There are " .. count .. " books in the database.")

local example = [[ books:find(2) ]]
print("Testing: " .. example)
res = books:find(2)
assert(res.title == "Gardens for dry climates")
print("OK")

example = [[ books:find_first("author = ? and year_pub > ?", { "John Doe", 1995, order = "year_pub asc" }) ]]
print("Testing: " .. example)
res = books:find_first("author = ? and year_pub > ?", { "John Doe", 1995, order = "year_pub asc" })
assert(res.title == "Halfway to nowhere")
print("OK")

example = [[ books:find_all("author = ? and year_pub > ?", { "John Doe", 1995, order = "year_pub asc", count = 5, fields = {"id", "title" } }) ]]
print("Testing: " .. example)
res = books:find_all("author = ? and year_pub > ?", { "John Doe", 1995, order = "year_pub asc", count = 5, fields = {"id", "title" } })
assert(#res == 5)
print("OK")

example = [[ books:find_all_by_author_or_author{ "John Doe", "Jane Doe", order = "year_pub asc" } ]]
print("Testing: " .. example)
res = books:find_all_by_author_or_author{ "John Doe", "Jane Doe", order = "year_pub asc" }
assert(#res == 8)
print("OK")
