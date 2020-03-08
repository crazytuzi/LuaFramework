local Lplus = require("Lplus")
local type = type
local string = string
local stringmatch = string.match
local Enum = Lplus.Class()
do
  local def = Enum.define
  def.static("table", "=>", "table").make = function(definition)
    local defLen = #definition
    local curPos = 1
    local curValue = 0
    local curIndex = 1
    local result = {}
    while defLen >= curPos do
      local name = definition[curPos]
      if type(name) ~= "string" then
        error(("bad enumerate #%d item name (string expected, got %s)"):format(curIndex, type(name)))
      end
      if result[name] then
        error(("duplicated enumerate #%d item name (%s)"):format(curIndex, name))
      end
      if not stringmatch(name, "^[%a_][%w_]*$") then
        error(("invalid enumerate #%d item name ('%s')"):format(curIndex, name))
      end
      local value
      if definition[curPos + 1] == "=" then
        local assignedValue = definition[curPos + 2]
        if type(assignedValue) == "number" then
          value = assignedValue
        elseif type(assignedValue) == "string" then
          value = result[assignedValue]
          if value == nil then
            error(("enumerate #%d item assigning value not found ('%s')"):format(curIndex, assignedValue))
          end
        else
          error(("bad assigning value to enumerate #%d item (string expected, got %s)"):format(curIndex, type(assignedValue)))
        end
        curPos = curPos + 3
      else
        value = curValue
        curPos = curPos + 1
      end
      result[name] = value
      curValue = value + 1
      curIndex = curIndex + 1
    end
    return result
  end
end
return Enum.Commit()
