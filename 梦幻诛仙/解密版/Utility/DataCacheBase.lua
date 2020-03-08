local Lplus = require("Lplus")
local DataCacheBase = Lplus.Class("DataCacheBase")
local def = DataCacheBase.define
def.field("number")._maxSize = 15
def.field("table")._cacheVector = nil
def.field("table")._cacheMap = nil
def.method().Init = function(self)
  self._cacheVector = {}
  self._cacheMap = {}
end
def.method("number", "=>", "table").GetData = function(self, numberKey)
  local data = self._cacheMap[numberKey]
  if data ~= nil then
    local oldVector = self._cacheVector
    self._cacheVector = {}
    for k, v in pairs(oldVector) do
      if self:_GetDataKey(v) ~= numberKey then
        table.insert(self._cacheVector, v)
      end
    end
    table.insert(self._cacheVector, data)
    return data
  else
    local data = self:_GetData(numberKey)
    local size = #self._cacheVector
    if size >= self._maxSize then
      local first = self._cacheVector[1]
      local keyOfFirst = self:_GetDataKey(first)
      self._cacheMap[keyOfFirst] = nil
      local oldVector = self._cacheVector
      self._cacheVector = {}
      for i = 2, size do
        local v = oldVector[i]
        table.insert(self._cacheVector, v)
      end
    end
    table.insert(self._cacheVector, data)
    self._cacheMap[numberKey] = data
    return data
  end
end
def.virtual("number", "=>", "table")._GetData = function(self, key)
end
def.virtual("table", "=>", "number")._GetDataKey = function(self, data)
end
DataCacheBase.Commit()
return DataCacheBase
