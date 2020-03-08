local MODULE_NAME = (...)
local Lplus = require("Lplus")
local VoiceQuestionUtils = Lplus.Class(MODULE_NAME)
local instance
local def = VoiceQuestionUtils.define
def.static("=>", "table").LoadFeatureTbl = function()
  local retData
  local entries = DynamicData.GetTable(CFG_PATH.DATA_OPENID2ACTID)
  if entries == nil then
    warn(">>>>Load VOICEQUESTION DATA_OPENID2ACTID ERROR<<<<")
    return retData
  end
  retData = {}
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local openId = record:GetIntValue("openId")
    local actId = record:GetIntValue("activityId")
    retData[actId] = openId
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return retData
end
def.static("number", "=>", "number").GetDstActivityIdBySrcActId = function(actId)
  local retData = 0
  local record = DynamicData.GetRecord(CFG_PATH.DATA_VOICECFGID2SRC_ACT_CFG, actId)
  if record == nil then
    warn("Load voicequestion DATA_VOICECFGID2SRC_ACT_CFG error<<<<")
    return retData
  end
  local srcActId = record:GetIntValue("activityId")
  return srcActId
end
def.static("number", "=>", "table").GetVoiceQuestionActCfgByActId = function(actId)
  local retData
  local record = DynamicData.GetRecord(CFG_PATH.DATA_VOICEQUESTION_ACT_CFG, actId)
  if record == nil then
    warn("Load voicequestion DATA_VOICEQUESTION_ACT_CFG error<<<<")
    return retData
  end
  retData = {}
  retData.actId = record:GetIntValue("activityId")
  retData.openId = record:GetIntValue("openId")
  retData.targetActId = record:GetIntValue("targetActivityId")
  retData.needNum = record:GetIntValue("needNum")
  retData.npcId = record:GetIntValue("npcCfgid")
  retData.npcSrvcId = record:GetIntValue("npcRewardServiceCfgid")
  retData.hoverTipsId = record:GetIntValue("hoverTipsId")
  retData.maxTimes = record:GetIntValue("maxQuestionNum")
  return retData
end
def.static("=>", "table").LoadVoiceQuestionSrvcId2ActIds = function()
  local retData = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_VOICEQUESTION_ACT_CFG)
  if entries == nil then
    warn(">>>>Load VOICEQUESTION DATA_VOICEQUESTION_ACT_CFG ERROR<<<<")
    return retData
  end
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local npcSrvcId = record:GetIntValue("npcRewardServiceCfgid")
    local actId = record:GetIntValue("activityId")
    retData[npcSrvcId] = actId
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return retData
end
def.static("=>", "table").LoadSrcActIdList = function()
  local retData = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_VOICECFGID2SRC_ACT_CFG)
  if entries == nil then
    warn(">>>>Load VOICEQUESTION DATA_VOICECFGID2SRC_ACT_CFG ERROR<<<<")
    return retData
  end
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local voiceActId = record:GetIntValue("activityId")
    local srcActId = record:GetIntValue("targetActivityId")
    table.insert(retData, srcActId)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return retData
end
def.static("number", "=>", "table").GetQuestionCfgById = function(id)
  local retData
  local record = DynamicData.GetRecord(CFG_PATH.DATA_VOICEQUESTION_CFG, id)
  if record == nil then
    warn(">>>>Load voicequestion DATA_VOICEQUESTION_CFG error<<<<")
    return retData
  end
  retData = {}
  retData.id = record:GetIntValue("id")
  retData.questionContent = record:GetStringValue("questionDesc")
  retData.questionVoiceId = record:GetIntValue("questionVoice")
  retData.answerVoiceId = record:GetIntValue("questionAnswerVoice")
  return retData
end
return VoiceQuestionUtils.Commit()
