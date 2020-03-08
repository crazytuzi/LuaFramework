local Lplus = require("Lplus")
local NewFunctionData = Lplus.Class("NewFunctionData")
local def = NewFunctionData.define
local instance
def.static("=>", NewFunctionData).Instance = function()
  if instance == nil then
    instance = NewFunctionData()
    instance:Init()
  end
  return instance
end
def.field("table")._newFunctionInfo = nil
def.method().Init = function(self)
  self:Reset()
end
def.method().Reset = function(self)
  self._newFunctionInfo = {}
end
NewFunctionData.Commit()
return NewFunctionData
