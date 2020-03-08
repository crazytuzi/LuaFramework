local Lplus = require("Lplus")
local YaoHunXianJiData = Lplus.Class("YaoHunXianJiData")
local def = YaoHunXianJiData.define
local instance
def.field("table")._cfgData = nil
def.static("=>", YaoHunXianJiData).Instance = function()
  if instance == nil then
    instance = YaoHunXianJiData()
  end
  return instance
end
def.method("number").InitData = function(self, actCfgId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_YAOHUNXIANJI, actCfgId)
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
  retData.effect_id = record:GetIntValue("effect_id")
  retData.effect_coord_x = record:GetIntValue("effect_coord_x")
  retData.effect_coord_y = record:GetIntValue("effect_coord_y")
  retData.desc = record:GetStringValue("desc")
  retData.need_pets = {}
  local vecStructData = record:GetStructValue("need_petsStruct")
  local vecSize = vecStructData:GetVectorSize("need_pets")
  for i = 1, vecSize do
    local vec_record = vecStructData:GetVectorValueByIdx("need_pets", i - 1)
    local needPetInfo = {}
    needPetInfo.pet_cfg_id = vec_record:GetIntValue("pet_cfg_id")
    needPetInfo.pet_num = vec_record:GetIntValue("pet_num")
    table.insert(retData.need_pets, needPetInfo)
  end
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
def.method("=>", "table").GetNeedPets = function(self)
  return self._cfgData.need_pets
end
def.method().Release = function(self)
  self._cfgData = nil
end
def.method("=>", "boolean").IsNil = function(self)
  return self._cfgData == nil
end
return YaoHunXianJiData.Commit()
