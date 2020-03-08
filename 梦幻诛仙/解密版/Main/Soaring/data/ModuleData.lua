local Lplus = require("Lplus")
local ModuleData = Lplus.Class("ModuleData")
local def = ModuleData.define
local instance
def.field("table")._cfgData = nil
def.static("=>", ModuleData).Instance = function()
  if instance == nil then
    instance = ModuleData()
    instance:InitData()
  end
  return instance
end
def.method().InitData = function(self)
end
def.method("number", "=>", "number").GetActivityCfgIdByModuleId = function(self, moduleId)
  if self._cfgData ~= nil then
    return self._cfgData
  end
  local record = DynamicData.GetRecord(CFG_PATH.DATA_SOARINGMODULE, moduleId)
  if record == nil then
    warn(">>>>Get Soaring cfg data error, moduleId =" .. moduleId .. "<<<<")
    return 0
  end
  if self._cfgData == nil then
    self._cfgData = {}
    self._cfgData.activity_cfg_id = record:GetIntValue("activity_cfg_id")
  end
  return self._cfgData.activity_cfg_id
end
def.method().Release = function(self)
  self._cfgData = nil
end
def.method("=>", "boolean").IsNil = function(self)
  return self._cfgData == nil
end
return ModuleData.Commit()
