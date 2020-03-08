local Lplus = require("Lplus")
local NewTermUtils = require("Main.NewTerm.NewTermUtils")
local AchievementData = require("Main.achievement.AchievementData")
local NewTermData = Lplus.Class("NewTermData")
local def = NewTermData.define
local _instance
def.static("=>", NewTermData).Instance = function()
  if _instance == nil then
    _instance = NewTermData()
  end
  return _instance
end
def.field("table")._displayCfg = nil
def.field("table")._actAchievementsCfg = nil
def.method().Init = function(self)
  self:_Reset()
end
def.method()._Reset = function(self)
  self._displayCfg = nil
  self._actAchievementsCfg = nil
end
def.method()._LoadDisplayCfg = function(self)
  warn("[NewTermData:_LoadDisplayCfg] start Load CNewTermDisplayCfg!")
  self._displayCfg = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CNewTermDisplayCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local displayCfg = {}
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    displayCfg.activityId = DynamicRecord.GetIntValue(entry, "id")
    displayCfg.titleTexId = DynamicRecord.GetIntValue(entry, "titleCfgid")
    displayCfg.tipId = DynamicRecord.GetIntValue(entry, "tips")
    self._displayCfg[displayCfg.activityId] = displayCfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("=>", "table")._GetDisplayCfgs = function(self)
  if nil == self._displayCfg then
    self:_LoadDisplayCfg()
  end
  return self._displayCfg
end
def.method("number", "=>", "table").GetDisplayCfg = function(self, id)
  return self:_GetDisplayCfgs()[id]
end
def.method("number", "=>", "number").GetTipId = function(self, activityId)
  local result = 0
  local displayCfg = self:GetDisplayCfg(activityId)
  if displayCfg then
    result = displayCfg.activityId
  else
    warn("[ERROR][NewTermData:GetTipId] displayCfg nil for activityId:", activityId)
  end
  return result
end
def.method()._LoadActAchievementsCfg = function(self)
  warn("[NewTermData:_LoadActAchievementsCfg] start Load AchievementsCfg!")
  self._actAchievementsCfg = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CNewTermAchievementsCfg)
  local actAchieveCount = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, actAchieveCount do
    local actAchievementCfg = {}
    local actAchieveEntry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    actAchievementCfg.activityId = DynamicRecord.GetIntValue(actAchieveEntry, "id")
    actAchievementCfg.subActivityCfgs = {}
    local achievementInfosStruct = actAchieveEntry:GetStructValue("achievementInfosStruct")
    local subActivityCount = achievementInfosStruct:GetVectorSize("achievementInfos")
    for k = 1, subActivityCount do
      local subActivityCfg = {}
      local subActivityRecord = achievementInfosStruct:GetVectorValueByIdx("achievementInfos", k - 1)
      subActivityCfg.activityId = subActivityRecord:GetIntValue("targetActivityCfgid")
      subActivityCfg.sortId = subActivityRecord:GetIntValue("sortid")
      subActivityCfg.parentActivityId = actAchievementCfg.activityId
      subActivityCfg.achievements = {}
      local achievementsStruct = subActivityRecord:GetStructValue("achievementsStruct")
      local achievementCount = achievementsStruct:GetVectorSize("achievements")
      for j = 1, achievementCount do
        local achievementRecord = achievementsStruct:GetVectorValueByIdx("achievements", j - 1)
        local achievementId = achievementRecord:GetIntValue("achievementId")
        table.insert(subActivityCfg.achievements, achievementId)
      end
      table.insert(actAchievementCfg.subActivityCfgs, subActivityCfg)
    end
    self._actAchievementsCfg[actAchievementCfg.activityId] = actAchievementCfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("=>", "table").GetActAchievementsCfgs = function(self)
  if nil == self._actAchievementsCfg then
    self:_LoadActAchievementsCfg()
  end
  return self._actAchievementsCfg
end
def.method("number", "=>", "table").GetActAchievementsCfg = function(self, activityId)
  return self:GetActAchievementsCfgs()[activityId]
end
def.method("table", "=>", "number", "number").GetSubActivityProgress = function(self, subActivityCfg)
  local curCount = 0
  local goalCount = 0
  local achievements = subActivityCfg and subActivityCfg.achievements
  if achievements and #achievements > 0 then
    local lastAchieveId = achievements[#achievements]
    curCount, goalCount = self:GetAchievemntProgress(subActivityCfg.parentActivityId, lastAchieveId)
  else
    warn("[ERROR][NewTermData:GetSubActivityProgress] achievements empty for subActivityCfg.activityId:", subActivityCfg and subActivityCfg.activityId)
  end
  return curCount, goalCount
end
def.method("number", "number", "=>", "number", "number").GetAchievemntProgress = function(self, activityId, achievementId)
  local AchievementFinishInfo = require("Main.achievement.AchievementFinishInfo")
  local curCount = 0
  local goalCount = 0
  local achieveCfg = AchievementData.GetAchievementGoalCfg(achievementId)
  local achieveInfo = self:GetAchievementInfo(activityId, achievementId)
  local achieveParams = achieveInfo and achieveInfo.parameters or nil
  if achieveParams == nil then
    achieveParams = {0, 0}
  end
  if achieveCfg and achieveParams then
    curCount, goalCount = AchievementFinishInfo.getFinishInfoData(achieveCfg, achieveParams)
  else
    warn(string.format("[ERROR][NewTermData:GetAchievemntProgress] achieveCfg or achieveParams nil for achievementId[%d]:", achievementId), achieveCfg, achieveParams)
  end
  return curCount, goalCount
end
def.method("number", "number", "=>", "table").GetAchievementInfo = function(self, activityId, achievementId)
  local actAchieveInfos = AchievementData.Instance():getAchievementGoalInfos(activityId)
  local achieveInfo = actAchieveInfos and actAchieveInfos[achievementId] or nil
  return achieveInfo
end
def.method("table", "=>", "boolean").HasUnfetchedAward = function(self, actAchievementCfg)
  local subActivityCfgs = actAchievementCfg and actAchievementCfg.subActivityCfgs
  if subActivityCfgs and #subActivityCfgs > 0 then
    local bHasUnfetchedAward = false
    local activityId = actAchievementCfg.activityId
    for _, subActivityCfg in pairs(subActivityCfgs) do
      local achievements = subActivityCfg.achievements
      if achievements and #achievements > 0 then
        for _, achieveId in pairs(achievements) do
          local achieveInfo = self:GetAchievementInfo(activityId, achieveId)
          if achieveInfo and achieveInfo.state == 2 then
            bHasUnfetchedAward = true
            break
          end
        end
      end
    end
    return bHasUnfetchedAward
  else
    return false
  end
end
def.method("table", "table").OnLeaveWorld = function(self, p1, p2)
  self:_Reset()
end
NewTermData.Commit()
return NewTermData
