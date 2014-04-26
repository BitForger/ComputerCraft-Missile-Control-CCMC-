--[[
Author: TheOriginalBIT
Version: 2.1
Created: 9 March 2013
Last Update: 22 September 2013

License:

COPYRIGHT NOTICE
Copyright © 2013 Joshua Asbury a.k.a TheOriginalBIT [theoriginalbit@gmail.com]

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
copies of the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
- Visible credit is given to the original author.
- The software is distributed in a non-profit way.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]--

local function startsWith(str, prefix)
  return str:sub( 1, #tostring(prefix)) == tostring(prefix)
end

local function contains(str, seq)
  return (str:find(seq, 1)) ~= nil
end

local function split(str, patt)
  local t = {}
  
  for s in str:gmatch("[^"..patt.."]+") do
    t[#t+1] = s
  end

  return t
end

local function trim(str)
  return (str:gsub("^%s*(.-)%s*$", "%1"))
end

local function log2(n)
  return math.floor(math.log(n) / math.log(2))
end

local function assert( _condition, _message, _level )
  _level = tonumber( _level ) or 1
  _level = _level == 0 and 0 or (_level + 1)
  if not _condition then
    error( _message or "assertion failed!", _level )
  end
  return _condition
end

local Configuration = {}

Configuration.__index = Configuration

local function validateParam(param, value)
  return type(param) == value
end

local function validateBoolean(b)
  return (b == "true" or b == "false" or b == "1" or b == "0" or b == 1 or b == 0 or b == true or b == false or b == "yes" or b == "no")
end

local function buildPattern(word)
 local result = ""
 for ixLetter = 1, #word do
  result = string.format("%s[%s%s]", result, string.lower(string.sub(word, ixLetter, ixLetter)), string.upper(string.sub(word, ixLetter, ixLetter)))
  if ixLetter < #word then result = result .. "%s*" end
 end
 return result
end

local function parseColor(source)
 source = source:gsub("colou?rs\.", "")
 for key, value in pairs(colors) do source = source:gsub(buildPattern(key), tostring(value)) end
 for key, value in pairs(colours) do source = source:gsub(buildPattern(key), tostring(value)) end
 return tonumber(source)
end

local function validateColor(col)
  if tonumber(col) then
    -- convert it down to incremental numbering aiming to see 0-15 here
    local shifted = log2(tonumber(col))
    -- make sure it is 0-15
    if shifted%1 == 0 and shifted >= 0 and shifted <= 15 then
      return true, col
    end
  elseif type(col) == "string" then
    col = parseColor(col)
    if col then
      return true, col
    end
  end

  return false
end

function new(path, name)
  assert(validateParam(path, "string"), "Invalid parameter #1: Expected string, got "..type(path), 2)
  assert(validateParam(name, "string"), "Invalid parameter #2: Expected string, got "..type(name), 2)

  return setmetatable({name = name:upper(), path = path, properties = {}}, Configuration)
end

function init(path, name)
  assert(validateParam(path, "string"), "Invalid parameter #1: Expected string, got "..type(path), 2)
  assert(validateParam(name, "string"), "Invalid parameter #2: Expected string, got "..type(name), 2)

  return setmetatable({name = name:upper(), path = path, properties = {}}, Configuration)
end

local function get(self, key, default)
  if type(self.properties[key]) == "table" then
    self.properties[key].default = default
    return self.properties[key].value
  end
  --# the key doesn't exist in the table, create it now
  self.properties[key] = {}
  self.properties[key].value = default
  self.properties[key].default = default
  return default
end

local function set(self, key, value)
  assert(self.properties[key], "Invalid parameter #1: The key '"..tostring(key).."' does not exist in the configuration file.", 3)

  self.properties[key].value = value
end

function Configuration:getBoolean(key, default)
  --# validate parameters
  assert(validateParam(key, "string"), "Invalid parameter #1: Expected string, got "..type(key), 2)
  assert(validateBoolean(default), "Invalid parameter #2: Expected boolean, got "..tostring(default).." of type "..type(default), 2)

  --# get the value from the config
  local value = get(self, key, default)

  --# validate the config boolean
  assert(validateBoolean(value), "Configuration error: No boolean value found under the key \""..key.."\", found "..tostring(value).." of type "..type(value), 2)

  --# return a boolean
  return v == "true" or v == true or v == "1" or v == 1 or v == "yes"
end

function Configuration:setBoolean(key, value)
  --# validate parameters
  assert(validateParam(key, "string"), "Invalid parameter #1: Expected string, got "..type(key), 2)
  assert(validateBoolean(value), "Invalid parameter #2: Expected boolean, got "..tostring(default).." of type "..type(value), 2)

  --# set the value
  set(self, key, value)
end

function Configuration:getNumber(key, default)
  --# validate parameters
  assert(validateParam(key, "string"), "Invalid parameter #1: Expected string, got "..type(key), 2)
  assert(validateParam(default, "number"), "Invalid parameter #2: Expected number, got "..tostring(default).." of type "..type(default), 2)

  --# get the number from the config
  local value = tonumber(get(self, key, default))

  --# validate the number
  assert(validateParam(value, "number"), "Configuration error: No number found under the key \""..key.."\", found "..tostring(value).." of type "..type(value), 2)

  --# return the number
  return value
end

function Configuration:setNumber(key, value)
  --# validate parameters
  assert(validateParam(key, "string"), "Invalid parameter #1: Expected string, got "..type(key), 2)
  assert(validateParam(value, "number"), "Invalid parameter #2: Expected number, got "..tostring(default).." of type "..type(value), 2)

  --# set the value
  set(self, key, value)
end

function Configuration:getString(key, default)
  --# validate parameters
  assert(validateParam(key, "string"), "Invalid parameter #1: Expected string, got "..type(key), 2)
  assert(validateParam(default, "string"), "Invalid parameter #2: Expected string, got "..tostring(default).." of type "..type(default), 2)

  --# get the string from the config
  local value = get(self, key, default)

  --# return the string
  return value
end

function Configuration:setString(key, value)
  --# validate parameters
  assert(validateParam(key, "string"), "Invalid parameter #1: Expected string, got "..type(key), 2)
  assert(validateParam(value, "string"), "Invalid parameter #2: Expected string, got "..tostring(default).." of type "..type(value), 2)

  --# set the value
  set(self, key, value)
end

function Configuration:getColor(key, default)
  --# validate parameters
  assert(validateParam(key, "string"), "Invalid parameter #1: Expected string, got "..type(key), 2)
  local ok, value = validateColor(default)
  assert(ok, "Invalid parameter #2: Expected number/color, got "..tostring(default).." of type "..type(default), 2)

  --# get the colour from the config
  ok, value = validateColor(get(self, key, default))

  --# validate the colour
  assert(ok, "Configuration error: No number/color found under the key\""..key.."\", found "..tostring(value).." of type "..type(value), 2)

  --# add the restriction comment
  self.properties[key].restrict = "A number between 1 and 32768 or the string colors.<color>"

  return value
end

function Configuration:setColor(key, value)
  --# validate parameters
  assert(validateParam(key, "string"), "Invalid parameter #1: Expected string, got "..type(key), 2)
  local ok, value = validateColor(value)
  assert(ok, "Invalid parameter #2: Expected number/color, got "..tostring(default).." of type "..type(default), 2)

  --# set the value
  set(self, key, value)
end

--# add the non-English (US) function
Configuration.getColour = Configuration.getColor

function Configuration:containsKey(key)
  return (self.properties[key] ~= nil)
end

function Configuration:load()
  --# make sure the file exists
  if not fs.exists(self.path) then
    return false
  end

  --# read the file
  local h = fs.open(self.path, 'r')
  assert(h, "Cannot open configuration file \'"..self.path.."\' for read")
  local contents = h.readAll()
  h.close()

  --# make sure there are contents of the file
  if not contents then
    return
  end

  local count = 1
  
  contents = split(contents, '\n')
  
  for i = 1, #contents do
    local v = trim(contents[i])
    if v and v ~= "" and not startsWith(v, "+--") and contains(v, '=') then
      local prop = split(v, '=')
      local key = trim(prop[1])
      local value = trim(prop[2])
      self.properties[key] = {}
      self.properties[key]["value"]   = value
      self.properties[key]["default"] = value
    elseif v and v ~= "" and not startsWith(v,"+--") and not contains(v, '=') then
      error("[\""..self.path.."\"] Cannot parse line #"..i.." in configuration file", 0)
    end
  end
  return true
end

function Configuration:reset(key)
  assert(type(self) == "table" and type(self.properties) == "table", "Cannot resetting config, have you forgotten to load the config?", 2)
  assert((key and self.properties[key]) or not key, "No property for key "..tostring(key)..", have you forgotten to load the config?", 2)

  if key then
    self.properties[key].value = self.properties[key].default
  else
    for k,_ in pairs(self.properties) do
      self.properties[k].value = self.properties[k].default
    end
  end
end

function Configuration:save()
  --# open the config file
  local h = fs.open(self.path, 'w')

  --# write the header
  h.write(string.format("\n+-- %s CONFIGURATION FILE\n+-- Generated by TheOriginalBIT's ccConfig\n\n\n", self.name))
  
  --# loop through the properties
  for k,v in pairs(self.properties) do
    --# write the properties info to file
    h.write(string.format("+-- %s restrictions: %s; default: %s;\n%s=%s\n\n\n", v.comment or "", v.restrict or "none", tostring(v.default), tostring(k), tostring(v.value)))

    --# flush the file
    h.flush()
  end
  
  --# close the file
  h.close()
end

function Configuration:addCommentForKey(key, value)
  --# validate parameters
  assert(validateParam(key, "string"), "Invalid parameter #1: Expected string, got "..type(key), 2)
  assert(self.properties[key], "Invalid parameter #1: No property with key \""..tostring(key).."\" to add comment", 2)

  --# add the comment
  self.properties[key].comment = value
end

function Configuration:addRestrictionForKey(key, value)
  --# validate parameters
  assert(validateParam(key, "string"), "Invalid parameter #1: Expected string, got "..type(key), 2)
  assert(self.properties[key], "No property with key \""..tostring(key).."\" to add comment", 2)

  --# add the restriction comment
  self.properties[key].restrict = value
end

function Configuration:debug(toFile)
  toFile = (toFile == true)
  local h = toFile and fs.open("debug", 'w') or nil
  for k,v in pairs(self.properties) do
    if toFile then
      h.write(k..":"..v.value.."\n")
    else
      print(k..":"..v.value)
    end
  end
  if toFile then
    h.close()
  end
end