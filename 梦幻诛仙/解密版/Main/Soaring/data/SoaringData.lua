local Lplus = require("Lplus")
local SoaringData = Lplus.Class("SoaringData")
local def = SoaringData.define
local instance
def.field("table")._cfgData = nil
def.static("number", "=>", SoaringData).Instance = function(actCfgId)
  if instance == nil then
    instance = SoaringData()
    instance:InitData(actCfgId)
  end
  return instance
end
def.method("number").InitData = function(self, actCfgId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_SOARING, actCfgId)
  if record == nil then
    warn(">>>>Load ancient seal data error, actCfgId = " .. actCfgId .. "<<<<")
    return
  end
  self._cfgData = {}
  local retData = self._cfgData
  retData.moduleid = record:GetIntValue("moduleid")
  retData.activity_cfg_id = record:GetIntValue("activity_cfg_id")
  retData.activity_map_cfg_id = record:GetIntValue("activity_map_cfg_id")
  retData.activity_map_transfer_x = record:GetIntValue("activity_map_transfer_x")
  retData.activity_map_transfer_y = record:GetIntValue("activity_map_transfer_y")
  retData.level = record:GetIntValue("level")
  retData.task_graph_id = record:GetIntValue("task_graph_id")
  retData.serverlevel = record:GetIntValue("serverlevel")
  retData.not_complete_effect_id = record:GetIntValue("not_complete_effect_id")
  retData.complete_effect_id = record:GetIntValue("complete_effect_id")
  retData.effect_coord_x = record:GetIntValue("effect_coord_x")
  retData.effect_coord_y = record:GetIntValue("effect_coord_y")
  retData.ui_complete_effect_id = record:GetIntValue("ui_complete_effect_id")
  retData.sub_activity_cfg_ids = {}
  local vecStructData = record:GetStructValue("sub_activity_cfg_idsStruct")
  local vecSize = vecStructData:GetVectorSize("sub_activity_cfg_ids")
  for i = 1, vecSize do
    local vec_record = vecStructData:GetVectorValueByIdx("sub_activity_cfg_ids", i - 1)
    local subActId = vec_record:GetIntValue("sub_activity_cfg_id")
    table.insert(retData.sub_activity_cfg_ids, subActId)
  end
end
def.method("=>", "number").GetActivityId = function(self)
  return self._cfgData.activity_cfg_id
end
def.method("=>", "number").GetTaskGraphId = function(self)
  return self._cfgData.task_graph_id
end
def.method("=>", "table").GetTaskMapTransferCoordinate = function(self)
  return {
    x = self._cfgData.activity_map_transfer_x,
    y = self._cfgData.activity_map_transfer_y
  }
end
def.method("=>", "number").GetMinLevel = function(self)
  return self._cfgData.level
end
def.method("=>", "table").GetSubtaskCfgIds = function(self)
  return self._cfgData.sub_activity_cfg_ids
end
def.method("=>", "number").CountSubtask = function(self)
  return #self._cfgData.sub_activity_cfg_ids
end
def.method("=>", "number").GetMapId = function(self)
  return self._cfgData.activity_map_cfg_id
end
def.method("=>", "number").GetSeverLevel = function(self)
  return self._cfgData.serverlevel or 0
end
def.method("=>", "table").GetEffectInfo = function(self)
  return {
    effectId = self._cfgData.complete_effect_id,
    x = self._cfgData.effect_coord_x,
    y = self._cfgData.effect_coord_y
  }
end
def.method("=>", "table").GetActImcompleteInfo = function(self)
  return {
    effectId = self._cfgData.not_complete_effect_id,
    x = self._cfgData.effect_coord_x,
    y = self._cfgData.effect_coord_y
  }
end
def.method("=>", "number").GetActCompleteUIEffect = function(self)
  return self._cfgData.ui_complete_effect_id
end
def.method().Release = function(self)
  self._cfgData = nil
end
def.method("=>", "boolean").IsNil = function(self)
  return self._cfgData == nil
end
return SoaringData.Commit()
