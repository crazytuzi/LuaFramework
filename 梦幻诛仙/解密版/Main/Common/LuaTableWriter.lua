local Lplus = require("Lplus")
local LuaTableWriter = Lplus.Class("LuaTableWriter")
local def = LuaTableWriter.define
local instance
local StringBuilder = {}
function StringBuilder.new(...)
  local stringBuilder = setmetatable({}, StringBuilder)
  StringBuilder.__index = StringBuilder
  stringBuilder:ctor(...)
  return stringBuilder
end
function StringBuilder:__tostring()
  return table.concat(self.data)
end
function StringBuilder:ctor()
  self.data = {}
end
function StringBuilder:push_back(v, nums)
  nums = nums or 1
  for i = 1, nums do
    self.data[#self.data + 1] = v
  end
end
function StringBuilder:tostring()
  return tostring(self)
end
local function serialize(strBuilder, o, level)
  local level = level or 1
  if type(o) == "number" then
    strBuilder:push_back(o)
  elseif type(o) == "string" then
    strBuilder:push_back(string.format("%q", o))
  elseif type(o) == "table" then
    strBuilder:push_back("{")
    for i, v in ipairs(o) do
      serialize(strBuilder, v, level + 1)
      strBuilder:push_back(",")
    end
    local listStart = 1
    local listLen = #o
    for k, v in pairs(o) do
      if type(k) == "number" and k >= listStart and k <= listLen then
      else
        strBuilder:push_back("\n")
        strBuilder:push_back("\t", level)
        if type(k) == "number" then
          strBuilder:push_back(string.format("[%d]", k))
        else
          strBuilder:push_back(string.format("[%q]", k))
        end
        strBuilder:push_back(" = ")
        serialize(strBuilder, v, level + 1)
        strBuilder:push_back(",")
      end
    end
    strBuilder:push_back("\n")
    strBuilder:push_back("\t", level - 1)
    strBuilder:push_back("}")
  elseif type(o) == "userdata" then
    strBuilder:push_back(string.format("%q", tostring(o)))
  elseif type(o) == "boolean" then
    strBuilder:push_back(tostring(o))
  else
    error("cannot serialize a " .. type(o))
  end
end
def.static("string", "string", "table").SaveTable = function(name, path, paramTable)
  local strBuilder = StringBuilder.new()
  strBuilder:push_back(string.format("local %s = ", name))
  serialize(strBuilder, paramTable)
  strBuilder:push_back(string.format([[

return %s]], name))
  local fileHandle, errorMessage = io.open(path, "wb")
  if fileHandle == nil then
    Debug.LogError(errorMessage .. "\n" .. debug.traceback())
    return
  end
  fileHandle:write(strBuilder:tostring())
  fileHandle:close()
end
return LuaTableWriter.Commit()
