local Lplus = require("Lplus")
local InstanceCommon = Lplus.Class("InstanceCommon")
local def = InstanceCommon.define
def.field("table").Data = function()
  return {}
end
local theData
def.static("=>", InstanceCommon).Instance = function()
  if theData == nil then
    theData = InstanceCommon()
    local ret
    ret, theData.Data = pcall(dofile, "Configs/instance_common_data.lua")
  end
  return theData
end
def.method("number", "=>", "table").GetData = function(self, id)
  local param = self.Data[id]
  return param
end
def.method("number", "=>", "boolean").IsItemCeconvertInst = function(self, id)
  local cfg = self.Data[id]
  if cfg ~= nil and string.find(cfg.limit, "no_item_reconvert") ~= nil then
    return false
  end
  return true
end
InstanceCommon.Commit()
return InstanceCommon
