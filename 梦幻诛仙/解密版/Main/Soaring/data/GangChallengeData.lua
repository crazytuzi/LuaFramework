local Lplus = require("Lplus")
local GangChallengeData = Lplus.Class("GangChallengeData")
local def = GangChallengeData.define
local instance
def.field("table")._cfgData = nil
def.static("=>", GangChallengeData).Instance = function()
  if instance == nil then
    instance = GangChallengeData()
  end
  return instance
end
def.method("number").InitData = function(self, actCfgId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GANGCHALLENGE, actCfgId)
  if record == nil then
    warn(">>>>Load gang challenge data error, actCfgId = " .. actCfgId .. "<<<<")
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
  retData.daily_get_team_member_award_max_times = record:GetIntValue("daily_get_team_member_award_max_times")
  retData.desc = record:GetStringValue("desc")
  retData.fight_infos = {}
  local vecStructData = record:GetStructValue("fight_infosStruct")
  local vecSize = vecStructData:GetVectorSize("fight_infos")
  for i = 1, vecSize do
    local vec_record = vecStructData:GetVectorValueByIdx("fight_infos", i - 1)
    local fight_info = {}
    fight_info.image_id = vec_record:GetIntValue("image_id")
    fight_info.sort_id = vec_record:GetIntValue("sort_id")
    table.insert(retData.fight_infos, fight_info)
  end
end
def.method("=>", "number").CountFightInfos = function(self)
  return #self._cfgData.fight_infos
end
def.method("=>", "table").GetChallengeInfos = function(self)
  return self._cfgData.fight_infos
end
def.method("=>", "number").GetActivityId = function(self)
  return self._cfgData.activity_cfg_id
end
def.method("=>", "number").GetNPCId = function(self)
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
def.method("=>", "number").GetTeamMemberAwardMaxTimes = function(self)
  return self._cfgData.daily_get_team_member_award_max_times
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
return GangChallengeData.Commit()
