local Lplus = require("Lplus")
local newproxy = newproxy
local getmetatable = getmetatable
local pairs = pairs
local checkNonNil = function(value, who, argIndex, errLevel)
  if value == nil then
    error(("bad argument #%d to %s in 'TableProxy' (non-nil expected, got nil)"):format(argIndex, who), errLevel + 1)
  end
end
local checkSimpleType = function(value, who, argIndex, needType, errLevel)
  if type(value) ~= needType then
    error(("bad argument #%d to %s in 'TableProxy' (%s expected, got %s)"):format(argIndex, who, needType, type(value)), errLevel + 1)
  end
end
local TableProxy = Lplus.Class()
do
  local def = TableProxy.define
  local function createProxy(__index)
    local proxy = newproxy(true)
    local meta = getmetatable(proxy)
    meta.__index = __index
    function meta.__newindex(t, k)
      error("bad writing to readonly table with key: " .. tostring(k), 2)
    end
    return proxy
  end
  local createTable = function(__index)
    return setmetatable({}, {__index = __index})
  end
  def.static("table", "=>", "table").createReadonlyTable = function(table)
    return createTable(table)
  end
  def.static("table", "=>", "userdata").createReadonlyProxy = function(table)
    return createProxy(table)
  end
  local function getPropertyTableIndexer(propertyTable, table, who)
    checkNonNil(propertyTable, who, 3)
    for k, v in pairs(propertyTable) do
      if type(v) ~= "function" then
        error(("bad argument #1 to '%s' (non function value with key: %s)"):format(who, tostring(k)), 3)
      end
    end
    return function(t, k)
      local prop = propertyTable[k]
      if prop then
        return prop()
      elseif table then
        return table[k]
      else
        return nil
      end
    end
  end
  def.static("table", "table", "=>", "table").createReadonlyPropertyTable = function(propertyTable, table)
    return createTable(getPropertyTableIndexer(propertyTable, table, "createReadonlyPropertyTable"))
  end
  def.static("table", "table", "=>", "userdata").createReadonlyPropertyProxy = function(propertyTable, table)
    return createProxy(getPropertyTableIndexer(propertyTable, table, "createReadonlyPropertyTable"))
  end
  def.static("=>", "table").createEnvClass = function()
    local EnvClass = Lplus.Class()
    do
      local def = EnvClass.define
      local infoMap = {}
      local infoMapProxy = TableProxy.createReadonlyProxy(infoMap)
      local infoEnv = TableProxy.createReadonlyTable(infoMap)
      def.static("=>", "userdata").getInfo = function()
        return infoMapProxy
      end
      def.static("=>", "table").getRawInfo = function()
        return infoMap
      end
      def.static("=>", "table").getEnv = function()
        return infoEnv
      end
      def.static("string", "dynamic").set = function(name, value)
        infoMap[name] = value
      end
    end
    return EnvClass.Commit()
  end
end
return TableProxy.Commit()
