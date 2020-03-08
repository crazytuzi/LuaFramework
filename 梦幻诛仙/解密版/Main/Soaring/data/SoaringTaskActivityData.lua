local Lplus = require("Lplus")
local SoaringTaskActivityData = Lplus.Class("SoaringTaskActivityData")
local def = SoaringTaskActivityData.define
local instance
def.field("table")._cfgData = nil
def.static("=>", SoaringTaskActivityData).Instance = function()
  if instance == nil then
    instance = SoaringTaskActivityData()
  end
  return instance
end
def.method("number").InitData = function(self, actCfgId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_SOARINGTASKACTDATA, actCfgId)
  if record == nil then
    warn(">>>>Load ancient seal data error, actCfgId = " .. actCfgId .. "<<<<")
    return
  end
  self._cfgData = {}
  local retData = self._cfgData
  retData.activity_cfg_id = record:GetIntValue("activity_cfg_id")
  retData.moduleid = record:GetIntValue("moduleid")
  retData.npc_id = record:GetIntValue("npc_id")
  retData.npc_service_id = record:GetIntValue("npc_service_id")
  retData.task_graph_id = record:GetIntValue("task_graph_id")
  retData.effect_id = record:GetIntValue("effect_id")
  retData.effect_coord_x = record:GetIntValue("effect_coord_x")
  retData.effect_coord_y = record:GetIntValue("effect_coord_y")
  retData.desc = record:GetStringValue("desc")
end
def.method("=>", "number").GetNPCId = function(self)
  if self._cfgData == nil then
    return 0
  end
  return self._cfgData.npc_id
end
def.method("=>", "number").GetNPCServiceId = function(self)
  return self._cfgData.npc_service_id
end
def.method("=>", "number").taskGraphId = function(self)
  return self._cfgData.task_graph_id
end
def.method("=>", "table").GetEffectInfo = function(self)
  return {
    effectId = self._cfgData.effect_id,
    x = self._cfgData.effect_coord_x,
    y = self._cfgData.effect_coord_y
  }
end
def.method("=>", "string").GetTalkContent = function(self)
  return self._cfgData.desc or ""
end
def.method().Release = function(self)
  self._cfgData = nil
end
def.method("=>", "boolean").IsNil = function(self)
  return self._cfgData == nil
end
return SoaringTaskActivityData.Commit()
