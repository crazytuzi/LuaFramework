local Lplus = require("Lplus")
local ChildrensDayUtils = Lplus.Class("ChildrensDayUtils")
local def = ChildrensDayUtils.define
def.static("=>", "table").GetAllActIds = function()
  local retData = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CHILDRENSDAY_MODULE_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local moduleId = record:GetIntValue("openCfgid")
    retData[moduleId] = record:GetIntValue("activityCfgid")
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return retData
end
def.static("number", "=>", "number").GetActIdByModuleId = function(moduleId)
  local allCfgData = ChildrensDayUtils.GetAllActIds()
  return allCfgData[moduleId] or 0
end
def.static("number", "=>", "table").GetRulesCfgByRuleId = function(ruleId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CHILDRENSDAY_RULES_CFG, ruleId)
  local retData = {}
  if record == nil then
    warn(">>>>Load DATA_CHILDRENSDAY_RULES_CFG error")
    return nil
  end
  retData.startCDTime = record:GetIntValue("drawCountdownTime")
  retData.RoundEndShowTime = record:GetIntValue("resultShowTime")
  retData.RoundTime = record:GetIntValue("roundContinueTime")
  retData.prepareTime = record:GetIntValue("waitMemberConfirmTime")
  retData.penCfgId = record:GetIntValue("penCfgid")
  return retData
end
def.static("number", "boolean", "=>", "table").GetGameRulesByActId = function(actId, bLoadRules)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CHILDRENSDAY_ACT_CFG, actId)
  local retData = {}
  if record == nil then
    warn(">>>>Load DATA_CHILDRENSDAY_ACT_CFG error...")
    return nil
  end
  retData.maxTeamMembersNum = record:GetIntValue("maxTeamMember")
  retData.minTeamMembersNum = record:GetIntValue("minTeamMember")
  retData.npcId = record:GetIntValue("npcCfgid")
  retData.npcServiceId = record:GetIntValue("npcServiceCfgid")
  retData.ruleId = record:GetIntValue("ruleId")
  if bLoadRules then
    local ruleCfgData = ChildrensDayUtils.GetRulesCfgByRuleId(retData.ruleId) or {}
    for k, v in pairs(ruleCfgData) do
      retData[k] = v
    end
  end
  return retData
end
def.static("=>", "table").GetAllQAs = function()
  local retData = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CHILDRENSDAY_MODULE_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local id = record:GetIntValue("id")
    retData[id] = {}
    local data = retData[id]
    data.question = record:GetStringValue("title")
    data.reminder = record:GetStringValue("reminder")
    data.answer = record:GetStringValue("answer")
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return retData
end
def.static("number", "=>", "table").GetQAContentById = function(id)
  local retData = {}
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CHILDRENSDAY_CONTENTS, id)
  if record == nil then
    warn(">>>>Load DATA_CHILDRENSDAY_CONTENTS by id = " .. id .. " error")
    return nil
  end
  retData.title = record:GetStringValue("title")
  retData.reminder = record:GetStringValue("reminder")
  return retData
end
def.static("number", "=>", "table").GetPenCfg = function(ruleId)
  local retData = {}
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CHILDRENSDAY_PEN_CFG, ruleId)
  warn(">>>>ruleId = " .. ruleId)
  if record == nil then
    warn(">>>>Load DATA_CHILDRENSDAY_PEN_CFG error")
    return nil
  end
  retData.colors = {}
  retData.sizes = {}
  for i = 1, 8 do
    local colorKey = string.format("color_%d", i)
    local sizeKey = string.format("size_%d", i)
    local color = record:GetStringValue(colorKey)
    table.insert(retData.colors, Color.Color(tonumber(string.sub(color, 2, 3), 16) / 255, tonumber(string.sub(color, 4, 5), 16) / 255, tonumber(string.sub(color, 6, 7), 16) / 255, 1))
    table.insert(retData.sizes, tonumber(record:GetFloatValue(sizeKey)))
  end
  return retData
end
def.static("number", "=>", "table").GetPenCfgByActId = function(actId)
  local rules = ChildrensDayUtils.GetGameRulesByActId(actId, true)
  return ChildrensDayUtils.GetPenCfg(rules.penCfgId)
end
return ChildrensDayUtils.Commit()
