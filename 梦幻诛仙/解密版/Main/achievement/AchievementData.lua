local Lplus = require("Lplus")
local AchievementData = Lplus.Class("AchievementData")
local OccupationEnum = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
local def = AchievementData.define
local instance
def.field("table").achievementInfos = nil
def.field("table").achievementTypeCfg = nil
def.field("table").achievementScoreCfg = nil
def.field("table").lastFinishAchievements = nil
def.field("boolean").IsGetAward = false
def.static("=>", AchievementData).Instance = function()
  if instance == nil then
    instance = AchievementData()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self.achievementInfos = {}
  self.lastFinishAchievements = {}
  self:InitTypeCfg()
  self:InitArchievementScoreCfg()
end
def.method().Reset = function(self)
  local bigTypeCountInfo = self.achievementTypeCfg.bigTypeCountInfo
  for _, countInfo in pairs(bigTypeCountInfo) do
    countInfo.curScore = 0
    countInfo.curCount = 0
  end
  self.IsGetAward = false
  self.lastFinishAchievements = {}
  self.achievementInfos = {}
end
def.static("number", "=>", "table").GetAchievementScoreCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ACHIEVEMENT_SCORE_CFG, id)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.score = record:GetIntValue("score")
  cfg.scoreIndexId = record:GetIntValue("scoreIndexId")
  cfg.awardId = record:GetIntValue("awardId")
  return cfg
end
def.static("number", "=>", "table").GetAchievementGoalCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CHIEVEMENT_GOAL_CFG, id)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.activityCfgId = record:GetIntValue("activityCfgId")
  cfg.goalType = record:GetIntValue("goalType")
  cfg.guideIndexId = record:GetIntValue("guideIndexId")
  cfg.title = record:GetStringValue("title")
  cfg.goalDes = record:GetStringValue("goalDes")
  cfg.iconId = record:GetIntValue("iconId")
  cfg.fixAwardId = record:GetIntValue("fixAwardId")
  cfg.rank = record:GetIntValue("rank")
  cfg.tapId = record:GetIntValue("tapId")
  cfg.point = record:GetIntValue("score")
  cfg.bulletinType = record:GetIntValue("bulletinType")
  cfg.paramPos = record:GetIntValue("paramPos")
  cfg.params = {}
  local rec2 = record:GetStructValue("parameterStruct")
  local count = rec2:GetVectorSize("parameter")
  for i = 1, count do
    local rec3 = rec2:GetVectorValueByIdx("parameter", i - 1)
    local param = rec3:GetIntValue("param")
    table.insert(cfg.params, param)
  end
  return cfg
end
def.static("number", "=>", "table").GetAchievementActivityCfg = function(activityId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ACHIEVEMENT_ACTIVITY_CFG, activityId)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.activityId = record:GetIntValue("activityId")
  cfg.goalCfgIdList = {}
  local rec2 = record:GetStructValue("goalCfgIdStruct")
  local count = rec2:GetVectorSize("goalCfgIdList")
  for i = 1, count do
    local rec3 = rec2:GetVectorValueByIdx("goalCfgIdList", i - 1)
    local goalId = rec3:GetIntValue("goalId")
    if goalId ~= 0 then
      table.insert(cfg.goalCfgIdList, goalId)
    end
  end
  return cfg
end
def.static("number", "=>", "table").GetAchievementScoreActivityCfg = function(activityId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ACHIEVEMENT_SCORE_ACTIVITY_CFG, activityId)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.activityId = record:GetIntValue("activityId")
  cfg.scoreCfgIdList = {}
  local rec2 = record:GetStructValue("scoreCfgIdStruct")
  local count = rec2:GetVectorSize("scoreCfgIdList")
  for i = 1, count do
    local rec3 = rec2:GetVectorValueByIdx("scoreCfgIdList", i - 1)
    local scoreId = rec3:GetIntValue("scoreCfgId")
    if scoreId ~= 0 then
      table.insert(cfg.scoreCfgIdList, scoreId)
    end
  end
  return cfg
end
def.method("number", "table", "table", "number").setAchievementInfo = function(self, activityId, goalinfos, getScoreAward, score)
  local info = {
    goalinfos = goalinfos,
    getScoreAward = getScoreAward,
    curScore = score
  }
  self.achievementInfos[activityId] = info
  if activityId == constant.AchievementConsts.activityId then
    local achievementCfg = self.achievementTypeCfg.achievementCfg
    local bigTypeCountInfo = self.achievementTypeCfg.bigTypeCountInfo
    for _, countInfo in pairs(bigTypeCountInfo) do
      countInfo.curScore = 0
      countInfo.curCount = 0
    end
    local sortTbl = {}
    for id, info in pairs(goalinfos) do
      if info.state == 2 or info.state == 3 then
        local cfg = achievementCfg[id]
        if cfg then
          local bigTypeId = cfg.bigTypeIndex
          local countInfo = bigTypeCountInfo[bigTypeId]
          local goalCfg = AchievementData.GetAchievementGoalCfg(id)
          countInfo.curScore = countInfo.curScore + goalCfg.point
          countInfo.curCount = countInfo.curCount + 1
        end
        table.insert(sortTbl, {
          id = id,
          time = info.achieve_time
        })
      end
    end
    self:UpdateLastFinishAchievement(sortTbl)
    self:UpdateAchievementScoreAward()
  end
end
def.method("table").UpdateLastFinishAchievement = function(self, achievements)
  table.sort(achievements, function(a, b)
    return a.time < b.time
  end)
  local maxCount = #achievements
  local begin = maxCount - 9
  if begin < 1 then
    begin = 1
  end
  self.lastFinishAchievements = {}
  for i = maxCount, begin, -1 do
    table.insert(self.lastFinishAchievements, achievements[i])
  end
end
def.method().UpdateAchievementScoreAward = function(self)
  local curScore = 0
  local getScoreAwardList = {}
  local info = self.achievementInfos[constant.AchievementConsts.activityId]
  if info then
    curScore = info.curScore
    local getScoreAward = info.getScoreAward
    for _, idx in pairs(getScoreAward) do
      getScoreAwardList[idx] = 1
    end
  end
  for i, scoreCfg in ipairs(self.achievementScoreCfg) do
    local achievementGetAward = 0
    if getScoreAwardList[i] == 1 then
      achievementGetAward = 1
    end
    if curScore < scoreCfg.score then
      self.IsGetAward = false
      return
    end
    if achievementGetAward == 0 then
      self.IsGetAward = true
      return
    end
  end
  self.IsGetAward = false
end
def.method("number", "number", "table", "number", "=>", "boolean").setAchievementGoalInfo = function(self, activityId, goalId, goalInfo, curScore)
  local info = self.achievementInfos[activityId]
  if info == nil then
    info = {
      goalinfos = {},
      getScoreAward = {},
      curScore = 0
    }
    self.achievementInfos[activityId] = info
  end
  local isFinishAchievement = false
  if activityId == constant.AchievementConsts.activityId then
    local achievements = info.goalinfos
    local achievementCfg = self.achievementTypeCfg.achievementCfg
    local bigTypeCountInfo = self.achievementTypeCfg.bigTypeCountInfo
    local cfg = achievementCfg[goalId]
    if cfg then
      local oldInfo = achievements[goalId]
      if (_G.IsNil(oldInfo) or oldInfo.state == 1) and (goalInfo.state == 2 or goalInfo.state == 3) then
        local bigTypeId = cfg.bigTypeIndex
        local countInfo = bigTypeCountInfo[bigTypeId]
        local goalCfg = AchievementData.GetAchievementGoalCfg(goalId)
        countInfo.curScore = countInfo.curScore + goalCfg.point
        countInfo.curCount = countInfo.curCount + 1
        table.insert(self.lastFinishAchievements, {
          id = goalId,
          time = goalInfo.achieve_time
        })
        self:UpdateLastFinishAchievement(self.lastFinishAchievements)
        isFinishAchievement = true
      end
    end
    self:UpdateAchievementScoreAward()
  end
  info.goalinfos[goalId] = goalInfo
  info.curScore = curScore
  return isFinishAchievement
end
def.method("number", "number").setAchievementScore = function(self, activityId, curScore)
  local info = self.achievementInfos[activityId]
  if info == nil then
    warn("!!!!!!!!!achievementInfo nil:", activityId)
    return
  end
  info.curScore = curScore
  if activityId == constant.AchievementConsts.activityId then
    self:UpdateAchievementScoreAward()
  end
end
def.method("number", "number", "number").setAchievementState = function(self, activityId, goalId, state)
  if activityId == constant.AchievementConsts.activityId then
    local achievements = self.achievementInfos[activityId].goalinfos
    local achievementCfg = self.achievementTypeCfg.achievementCfg
    local bigTypeCountInfo = self.achievementTypeCfg.bigTypeCountInfo
    local cfg = achievementCfg[goalId]
    if cfg then
      local oldInfo = achievements[goalId]
      if oldInfo and oldInfo.state == 1 and (state == 2 or state == 3) then
        local bigTypeId = cfg.bigTypeIndex
        local countInfo = bigTypeCountInfo[bigTypeId]
        local goalCfg = AchievementData.GetAchievementGoalCfg(goalId)
        countInfo.curScore = countInfo.curScore + goalCfg.point
        countInfo.curCount = countInfo.curCount + 1
        table.insert(self.lastFinishAchievements, {
          id = goalId,
          time = goalInfo.achieve_time
        })
        self:UpdateLastFinishAchievement(self.lastFinishAchievements)
      end
    end
  end
  self.achievementInfos[activityId].goalinfos[goalId].state = state
end
def.method("number", "number").setGetScoreAward = function(self, activityId, score)
  self.achievementInfos[activityId].getScoreAward[score] = score
  if activityId == constant.AchievementConsts.activityId then
    self:UpdateAchievementScoreAward()
  end
end
def.method("number", "=>", "table").getScoreAwardInfo = function(self, activityId)
  if self.achievementInfos[activityId] then
    return self.achievementInfos[activityId].getScoreAward
  end
  return nil
end
def.method("number", "=>", "table").getAchievementGoalInfos = function(self, activityId)
  if self.achievementInfos[activityId] then
    return self.achievementInfos[activityId].goalinfos
  end
  return nil
end
def.method("number", "=>", "number").getAchievementScore = function(self, activityId)
  if self.achievementInfos[activityId] then
    return self.achievementInfos[activityId].curScore
  end
  return 0
end
def.method().InitTypeCfg = function(self)
  if _G.IsNil(self.achievementTypeCfg) then
    self.achievementTypeCfg = {
      achievements = {}
    }
  end
  local subTypeCfg = {}
  local bigTypeCfg = {}
  local achievementCfg = {}
  local bigTypeCountInfo = {}
  local achievementTypeCfg = self.achievementTypeCfg
  local invisibleAchievementIndex = constant.AchievementConsts.invisibleAchievementIndex
  achievementTypeCfg.subTypeCfg = subTypeCfg
  achievementTypeCfg.bigTypeCfg = bigTypeCfg
  achievementTypeCfg.achievementCfg = achievementCfg
  achievementTypeCfg.bigTypeCountInfo = bigTypeCountInfo
  do
    local entries = DynamicData.GetTable(CFG_PATH.DATA_ACHIEVEMENT_SUBTYPE_CFG)
    local count = DynamicDataTable.GetRecordsCount(entries)
    DynamicDataTable.FastGetRecordBegin(entries)
    for i = 0, count - 1 do
      local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
      local data = {
        id = DynamicRecord.GetIntValue(entry, "id"),
        index = DynamicRecord.GetIntValue(entry, "index"),
        name = DynamicRecord.GetStringValue(entry, "name"),
        achievementList = {}
      }
      subTypeCfg[data.id] = data
    end
    DynamicDataTable.FastGetRecordEnd(entries)
  end
  do
    local entries = DynamicData.GetTable(CFG_PATH.DATA_ACHIEVEMENT_CFG)
    local count = DynamicDataTable.GetRecordsCount(entries)
    DynamicDataTable.FastGetRecordBegin(entries)
    for i = 0, count - 1 do
      local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
      local id = DynamicRecord.GetIntValue(entry, "goalCfgId")
      local subTypeCfgId = DynamicRecord.GetIntValue(entry, "subTypeCfgId")
      local achievementType = DynamicRecord.GetIntValue(entry, "achievementType")
      local goalCfg = AchievementData.GetAchievementGoalCfg(id)
      local data = {
        id = id,
        prevId = DynamicRecord.GetIntValue(entry, "previousGoalCfgId"),
        nextId = 0,
        menpai = DynamicRecord.GetIntValue(entry, "showOccupation"),
        subType = subTypeCfgId,
        rank = goalCfg and goalCfg.rank or 1
      }
      achievementCfg[id] = data
      local cfg = subTypeCfg[subTypeCfgId]
      if cfg and 0 >= data.prevId then
        table.insert(cfg.achievementList, data)
      end
    end
    DynamicDataTable.FastGetRecordEnd(entries)
    for id, cfg in pairs(achievementCfg) do
      if 0 < cfg.prevId then
        local prevCfg = achievementCfg[cfg.prevId]
        if prevCfg then
          prevCfg.nextId = id
        end
      end
    end
  end
  do
    local function SetAchievementCfgBigType(subType, bigTypeIndex)
      if subType then
        for _, cfg in pairs(subType.achievementList) do
          cfg.bigTypeIndex = bigTypeIndex
          while cfg.nextId > 0 do
            cfg = achievementCfg[cfg.nextId]
            cfg.bigTypeIndex = bigTypeIndex
          end
        end
      end
    end
    local entries = DynamicData.GetTable(CFG_PATH.DATA_ACHIEVEMENT_BIGTYPE_CFG)
    local count = DynamicDataTable.GetRecordsCount(entries)
    DynamicDataTable.FastGetRecordBegin(entries)
    for i = 0, count - 1 do
      local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
      local subTypeCfgIdStruct = DynamicRecord.GetStructValue(entry, "subTypeCfgIdStruct")
      local bigTypeIndex = DynamicRecord.GetIntValue(entry, "index")
      local subTypeIds = {}
      local subTypeVectorCount = DynamicRecord.GetVectorSize(subTypeCfgIdStruct, "subTypeCfgIds")
      for i = 0, subTypeVectorCount - 1 do
        local subTypeRecord = DynamicRecord.GetVectorValueByIdx(subTypeCfgIdStruct, "subTypeCfgIds", i)
        local subTypeCfgId = subTypeRecord:GetIntValue("subTypeCfgId")
        table.insert(subTypeIds, subTypeCfgId)
        SetAchievementCfgBigType(subTypeCfg[subTypeCfgId], bigTypeIndex)
      end
      local data = {
        index = bigTypeIndex,
        name = DynamicRecord.GetStringValue(entry, "name"),
        subTypeIdList = subTypeIds
      }
      if bigTypeIndex == invisibleAchievementIndex then
        achievementTypeCfg.bigTypeHideCfg = data
      else
        table.insert(bigTypeCfg, data)
      end
      bigTypeCountInfo[bigTypeIndex] = {
        maxScore = 0,
        maxCount = 0,
        curScore = 0,
        curCount = 0
      }
    end
    DynamicDataTable.FastGetRecordEnd(entries)
    table.insert(bigTypeCfg, {
      index = -1,
      name = textRes.Grow.Achievement[3],
      subTypeIdList = {}
    })
  end
  table.sort(bigTypeCfg, function(a, b)
    return a.index < b.index
  end)
  for _, bigType in ipairs(bigTypeCfg) do
    table.sort(bigType.subTypeIdList, function(a, b)
      local subTypeA = subTypeCfg[a]
      local subTypeB = subTypeCfg[b]
      if subTypeA and subTypeB then
        return subTypeA.index < subTypeB.index
      end
      return false
    end)
  end
end
def.method().ResetAchievementListAndCountInfo = function(self)
  local achievementTypeCfg = self.achievementTypeCfg
  local subTypeCfg = achievementTypeCfg.subTypeCfg
  local achievementCfg = achievementTypeCfg.achievementCfg
  local bigTypeCountInfo = achievementTypeCfg.bigTypeCountInfo
  local menpai = 0
  local myProp = require("Main.Hero.Interface").GetBasicHeroProp()
  if myProp then
    menpai = myProp.occupation
  end
  for _, countInfo in pairs(bigTypeCountInfo) do
    countInfo.maxCount = 0
    countInfo.maxScore = 0
  end
  for _, subType in pairs(subTypeCfg) do
    subType.achievementList = {}
  end
  for id, cfg in pairs(achievementCfg) do
    local bigTypeId = cfg.bigTypeIndex
    local countInfo = bigTypeCountInfo[bigTypeId]
    if cfg.menpai == OccupationEnum.ALL or cfg.menpai == menpai then
      local goalCfg = AchievementData.GetAchievementGoalCfg(id)
      if goalCfg then
        local subTypeInfo = subTypeCfg[cfg.subType]
        if subTypeInfo and 0 >= cfg.prevId then
          table.insert(subTypeInfo.achievementList, cfg)
        end
        countInfo.maxCount = countInfo.maxCount + 1
        countInfo.maxScore = countInfo.maxScore + goalCfg.point
      else
        warn("----------[error] achievement goalCfg not exsit!!", id)
      end
    end
  end
  if subTypeCfg then
    for subTypeId, subType in pairs(subTypeCfg) do
      local achievementList = subType.achievementList
      if achievementList and #achievementList > 0 then
        table.sort(achievementList, function(a, b)
          if a == nil then
            return true
          elseif b == nil then
            return false
          elseif a.rank ~= b.rank then
            return a.rank < b.rank
          else
            return a.id < b.id
          end
        end)
      else
      end
    end
  end
end
def.method().InitArchievementScoreCfg = function(self)
  if _G.IsNil(self.achievementScoreCfg) then
    self.achievementScoreCfg = {}
  end
  local activityId = constant.AchievementConsts.activityId
  local achievementScoreCfg = self.achievementScoreCfg
  local entries = DynamicData.GetTable(CFG_PATH.DATA_ACHIEVEMENT_SCORE_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local id = DynamicRecord.GetIntValue(entry, "id")
    local score = DynamicRecord.GetIntValue(entry, "score")
    local scoreIndexId = DynamicRecord.GetIntValue(entry, "scoreIndexId")
    local awardId = DynamicRecord.GetIntValue(entry, "awardId")
    local activityCfgId = DynamicRecord.GetIntValue(entry, "activityCfgId")
    if activityCfgId == activityId then
      local data = {
        id = id,
        score = score,
        scoreIndexId = scoreIndexId,
        awardId = awardId
      }
      table.insert(achievementScoreCfg, data)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("=>", "table").GetAchievementTypeList = function(self)
  local subTypeCfg = self.achievementTypeCfg.subTypeCfg
  local bigTypeHideCfg = self.achievementTypeCfg.bigTypeHideCfg
  if bigTypeHideCfg then
    local subTypeList = {}
    for _, subTypeCfgId in ipairs(bigTypeHideCfg.subTypeIdList) do
      local subTypeData = subTypeCfg[subTypeCfgId]
      if subTypeData then
        for _, cfg in pairs(subTypeData.achievementList) do
          local goalInfo = self:GetAchievementInfo(cfg.id)
          if goalInfo and (goalInfo.state == 2 or goalInfo.state == 3) then
            table.insert(subTypeList, subTypeCfgId)
            break
          end
        end
      end
    end
    if #subTypeList > 0 then
      local bigTypeList = {}
      for _, bigTypeData in ipairs(self.achievementTypeCfg.bigTypeCfg) do
        table.insert(bigTypeList, bigTypeData)
      end
      table.insert(bigTypeList, {
        index = bigTypeHideCfg.index,
        name = bigTypeHideCfg.name,
        subTypeIdList = subTypeList
      })
      table.sort(bigTypeList, function(a, b)
        return a.index < b.index
      end)
      return bigTypeList
    end
  end
  return self.achievementTypeCfg.bigTypeCfg
end
def.method("number", "=>", "table").GetAchievementSubTypeCfg = function(self, subTypeId)
  return self.achievementTypeCfg.subTypeCfg[subTypeId]
end
def.method("number", "=>", "table").GetAchievementCountInfo = function(self, bigTypeIndex)
  return self.achievementTypeCfg.bigTypeCountInfo[bigTypeIndex] or {
    curScore = 0,
    maxScore = 0,
    curCount = 0,
    maxCount = 0
  }
end
def.method("number", "=>", "table").GetAchievementInfo = function(self, id)
  local achievements = self:getAchievementGoalInfos(constant.AchievementConsts.activityId)
  if achievements then
    return achievements[id]
  end
  return nil
end
def.method("number", "=>", "table").GetAchievementCfg = function(self, id)
  return self.achievementTypeCfg.achievementCfg[id]
end
def.method("=>", "table").GetLastFinishAchievements = function(self)
  return self.lastFinishAchievements
end
def.method("=>", "table", "number").GetAchievementScoreInfoList = function(self)
  local listInfo = {}
  local curScore = 0
  local getScoreAwardList = {}
  local info = self.achievementInfos[constant.AchievementConsts.activityId]
  if info then
    curScore = info.curScore
    local getScoreAward = info.getScoreAward
    for _, idx in pairs(getScoreAward) do
      getScoreAwardList[idx] = 1
    end
  end
  for i, scoreCfg in ipairs(self.achievementScoreCfg) do
    local id = scoreCfg.id
    local isGetAward = 0
    if getScoreAwardList[i] == 1 then
      isGetAward = 1
    end
    local data = {
      id = id,
      score = scoreCfg.score,
      scoreIndexId = scoreCfg.scoreIndexId,
      awardId = scoreCfg.awardId,
      isGetAward = isGetAward
    }
    table.insert(listInfo, data)
  end
  return listInfo, curScore
end
def.method("=>", "boolean").CanGetAward = function(self)
  return self.IsGetAward
end
return AchievementData.Commit()
