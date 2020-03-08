local Lplus = require("Lplus")
local QingYunAskedData = Lplus.Class("QingYunAskedData")
local def = QingYunAskedData.define
local instance
def.field("table")._cfgData = nil
def.static("=>", QingYunAskedData).Instance = function()
  if instance == nil then
    instance = QingYunAskedData()
  end
  return instance
end
def.method("number").InitData = function(self, actCfgId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_QINGYUNASKED, actCfgId)
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
  retData.challenge_type = record:GetIntValue("challenge_type")
  retData.chapter_id = record:GetIntValue("chapter_id")
  retData.section_id = record:GetIntValue("section_id")
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
def.method("=>", "number").GetServiceId = function(self)
  if self._cfgData == nil then
    return 0
  end
  return self._cfgData.npc_service_id
end
def.method("=>", "number").GetQingYunZhiType = function(self)
  if self._cfgData == nil then
    return 0
  end
  return self._cfgData.challenge_type
end
def.method("=>", "number").GetChapterId = function(self)
  if self._cfgData == nil then
    return 0
  end
  return self._cfgData.chapter_id
end
def.method("=>", "number").GetSectionId = function(self)
  if self._cfgData == nil then
    return 0
  end
  return self._cfgData.section_id
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
return QingYunAskedData.Commit()
