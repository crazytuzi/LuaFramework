local Lplus = require("Lplus")
local AnniversaryUtils = Lplus.Class("AnniversaryUtils")
local def = AnniversaryUtils.define
def.static("number", "=>", "table").GetAnniversaryParadeCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ANNIVERSARY_PARADE_CFG, id)
  if record == nil then
    warn("[GetAnniversaryParadeCfg] get nil record for id: ", id)
    return nil
  end
  local cfg = {}
  cfg.activityId = record:GetIntValue("activityId")
  cfg.mapGroupId = record:GetIntValue("mapGroupId")
  cfg.mapUniqueTime = record:GetIntValue("mapUniqueTime")
  cfg.ocpGroupId = record:GetIntValue("ocpGroupId")
  cfg.ocpUniqueTime = record:GetIntValue("ocpUniqueTime")
  cfg.danceGroupId = record:GetIntValue("danceGroupId")
  cfg.redbagGroupId = record:GetIntValue("redbagGroupId")
  cfg.startCommonTimeId = record:GetIntValue("startCommonTimeId")
  cfg.periodInMinute = record:GetIntValue("periodInMinute")
  cfg.prepareEffectId = record:GetIntValue("prepareEffectId")
  cfg.prepareTime = record:GetIntValue("prepareTime")
  cfg.fireworksEffectId = record:GetIntValue("fireworksEffectId")
  cfg.flowerRadiusEffectId = record:GetIntValue("flowerRadiusEffectId")
  cfg.restTime = record:GetIntValue("restTime")
  cfg.singDelayTime = record:GetIntValue("singDelayTime")
  cfg.endEffectId = record:GetIntValue("endEffectId")
  cfg.endRestTime = record:GetIntValue("endRestTime")
  cfg.followAwardCount = record:GetIntValue("followAwardCount")
  cfg.danceAwardCount = record:GetIntValue("danceAwardCount")
  return cfg
end
def.static("number", "number", "=>", "table").GetParadeOccupationCfg = function(groupId, ocp)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PARADE_OCCUPATION_CFG, groupId)
  if record == nil then
    warn("[GetParadeOccupationCfg] get nil record for id: ", groupId)
    return nil
  end
  local groupStruct = record:GetStructValue("groupStruct")
  local count = groupStruct:GetVectorSize("ocpList")
  for i = 1, count do
    local rec = groupStruct:GetVectorValueByIdx("ocpList", i - 1)
    local _ocp = rec:GetIntValue("ocp")
    if _ocp == ocp then
      local data = {}
      data.effectId = rec:GetIntValue("effectId")
      data.flagId = rec:GetIntValue("flagId")
      data.modelId = rec:GetIntValue("modelId")
      data.ocp = _ocp
      data.ocpRole1 = rec:GetIntValue("ocpRole1")
      data.ocpRole2 = rec:GetIntValue("ocpRole2")
      data.radius = rec:GetIntValue("radius")
      return data
    end
  end
  return nil
end
def.static("number", "=>", "table").GetParadeDanceCfg = function(groupId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PARADE_DANCE_CFG, groupId)
  if record == nil then
    warn("[GetParadeDanceCfg] get nil record for id: ", groupId)
    return nil
  end
  local cfg = {}
  local groupStruct = record:GetStructValue("groupStruct")
  local count = groupStruct:GetVectorSize("danceList")
  for i = 1, count do
    local action = {}
    local rec = groupStruct:GetVectorValueByIdx("danceList", i - 1)
    action.id = rec:GetIntValue("actionId")
    action.tip = rec:GetStringValue("tip")
    cfg[i] = action
  end
  return cfg
end
def.static("number", "=>", "table").GetParadeRedbagCfg = function(groupId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PARADE_REDBAG_CFG, groupId)
  if record == nil then
    warn("[GetParadeRedbagCfg] get nil record for id: ", groupId)
    return nil
  end
  local cfg = {}
  local groupStruct = record:GetStructValue("groupStruct")
  local count = groupStruct:GetVectorSize("tipList")
  for i = 1, count do
    local rec = groupStruct:GetVectorValueByIdx("tipList", i - 1)
    local tip = rec:GetStringValue("tip")
    cfg[i] = tip
  end
  return cfg
end
def.static("number", "=>", "table").GetMakeUpCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ANNIVERSARY_MAKE_UP_CFG, id)
  if record == nil then
    warn("[GetMakeUpCfg] get nil record for id: ", id)
    return nil
  end
  local cfg = {}
  cfg.activityId = record:GetIntValue("activityId")
  cfg.finishEffectId = record:GetIntValue("finishEffectId")
  cfg.regionEffectId = record:GetIntValue("regionEffectId")
  cfg.optionNum = record:GetIntValue("optionNum")
  cfg.positionX = record:GetIntValue("positionX")
  cfg.positionY = record:GetIntValue("positionY")
  cfg.prepareTime = record:GetIntValue("prepareTime")
  cfg.questionLibId = record:GetIntValue("questionLibId")
  cfg.radius = record:GetIntValue("radius")
  cfg.specialAwardNeedNum = record:GetIntValue("specialAwardNeedNum")
  cfg.rounds = record:GetIntValue("rounds")
  cfg.roundTime = record:GetIntValue("roundTime")
  return cfg
end
def.static("number", "=>", "table").GetMakeUpOptionCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MAKE_UP_OPTION_CFG, id)
  if record == nil then
    warn("[GetMakeUpOptionCfg] get nil record for id: ", id)
    return nil
  end
  local cfg = {}
  cfg.optionName = record:GetStringValue("optionName")
  cfg.optionIcon = record:GetIntValue("optionIcon")
  cfg.changeBuffId = record:GetIntValue("changeBuffId")
  return cfg
end
def.static("number", "=>", "table").GetMakeUpQuestionCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MAKE_UP_QUESTION_CFG, id)
  if record == nil then
    warn("[GetMakeUpQuestionCfg] get nil record for id: ", id)
    return nil
  end
  local cfg = {}
  local questionStruct = record:GetStructValue("questionStruct")
  local count = questionStruct:GetVectorSize("tipList")
  for i = 1, count do
    local rec = questionStruct:GetVectorValueByIdx("tipList", i - 1)
    local tipDesc = rec:GetStringValue("tipDesc")
    cfg[i] = tipDesc
  end
  return cfg
end
AnniversaryUtils.Commit()
return AnniversaryUtils
