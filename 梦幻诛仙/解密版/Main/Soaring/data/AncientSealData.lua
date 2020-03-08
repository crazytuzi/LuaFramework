local Lplus = require("Lplus")
local AncientSealData = Lplus.Class("AncientSealData")
local def = AncientSealData.define
local instance
def.field("table")._cfgData = nil
def.static("=>", AncientSealData).Instance = function()
  instance = AncientSealData()
  return instance
end
def.method("number").InitData = function(self, actCfgId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ANCIENTSEAL, actCfgId)
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
  retData.display_item_cfg_id = record:GetIntValue("display_item_cfg_id")
  retData.effect_id = record:GetIntValue("effect_id")
  retData.effect_coord_x = record:GetIntValue("effect_coord_x")
  retData.effect_coord_y = record:GetIntValue("effect_coord_y")
  retData.desc = record:GetStringValue("desc")
  retData.need_items = {}
  local vecStructData = record:GetStructValue("need_itemsStruct")
  local vecSize = vecStructData:GetVectorSize("need_items")
  for i = 1, vecSize do
    local vec_record = vecStructData:GetVectorValueByIdx("need_items", i - 1)
    local itemInfo = {}
    itemInfo.item_cfg_id = vec_record:GetIntValue("item_cfg_id")
    itemInfo.item_num = vec_record:GetIntValue("item_num")
    table.insert(retData.need_items, itemInfo)
  end
end
def.method("=>", "number").GetNPCId = function(self)
  if self._cfgData == nil then
    return 0
  end
  return self._cfgData.npc_id
end
def.method("=>", "table").GetNeedsItems = function(self)
  if self._cfgData == nil then
    return nil
  end
  return self._cfgData.need_items
end
def.method("=>", "number").GetNPCServiceId = function(self)
  if self._cfgData == nil then
    return 0
  end
  return self._cfgData.npc_service_id
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
return AncientSealData.Commit()
