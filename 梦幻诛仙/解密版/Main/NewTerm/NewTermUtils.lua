local Lplus = require("Lplus")
local ActivityInterface = require("Main.activity.ActivityInterface")
local NewTermUtils = Lplus.Class("NewTermUtils")
local def = NewTermUtils.define
local AchieveAwardsState = {
  ALL_FETCHED = 1,
  NONE = 2,
  UNFETCHED = 3
}
def.static("number", "=>", "table").GetAwardItems = function(awardId)
  local ItemUtils = require("Main.Item.ItemUtils")
  local SOccupationEnum = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
  local SGenderEnum = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
  local key = string.format("%d_%d_%d", awardId, SOccupationEnum.ALL, SGenderEnum.ALL)
  local cfg = ItemUtils.GetGiftAwardCfg(key)
  local itemList = ItemUtils.GetAwardItemsFromAwardCfg(cfg)
  if itemList and itemList[1] then
    return itemList
  else
    return nil
  end
end
def.static("table", "=>", "table").GetSortedValidSubActs = function(actAchievementCfg)
  local result = {}
  local subActivityCfgs = actAchievementCfg and actAchievementCfg.subActivityCfgs
  if subActivityCfgs and #subActivityCfgs > 0 then
    for _, subActCfg in pairs(subActivityCfgs) do
      if NewTermUtils.CanAttendActivity(subActCfg.activityId, nil, false) then
        table.insert(result, subActCfg)
      end
    end
    table.sort(result, NewTermUtils.SortActAchievement)
  end
  return result
end
def.static("number", "table", "boolean", "=>", "boolean").CanAttendActivity = function(activityId, activityCfg, bToast)
  if nil == activityCfg then
    activityCfg = ActivityInterface.GetActivityCfgById(activityId)
  end
  if nil == activityCfg then
    warn("[ERROR][NewTermUtils:CanAttendActivity] activityCfg nil for id:", activityId)
    return false
  end
  if nil == _G.GetHeroProp() then
    warn("[ERROR][NewTermUtils:CanAttendActivity] _G.GetHeroProp() nil.")
    return false
  end
  if ActivityInterface.Instance():IsCustomCloseActivity(activityId) then
    return false
  end
  local myLevel = _G.GetHeroProp().level
  local bLevelValid = myLevel >= activityCfg.levelMin and myLevel <= activityCfg.levelMax
  if false == bLevelValid then
    if bToast then
      Toast(textRes.Carnival.LEVEL_INVALID)
    end
    return false
  end
  local isForceOpen = ActivityInterface.Instance():isForceOpenActivity(activityId)
  if isForceOpen then
    return true
  else
    local isForcePause = ActivityInterface.Instance():isActivityPause(activityId)
    local isForceClose = ActivityInterface.Instance():isForceCloseActivity(activityId)
    if isForcePause or isForceClose then
      if bToast then
        Toast(textRes.Carnival.ACTIVITY_CLOSED)
      end
      return false
    else
      return true
    end
  end
end
def.static("table", "table", "=>", "boolean").SortActAchievement = function(a, b)
  if a == nil then
    return true
  elseif b == nil then
    return false
  else
    local bAHas = NewTermUtils.GetAwardsState(a)
    local bBHas = NewTermUtils.GetAwardsState(b)
    if bAHas ~= bBHas then
      return bAHas > bBHas
    elseif a.sortId ~= b.sortId then
      return a.sortId < b.sortId
    else
      return a.activityId < b.activityId
    end
  end
end
def.static("table", "=>", "number").GetAwardsState = function(subActivityCfg)
  local awardsState = AchieveAwardsState.NONE
  local achievements = subActivityCfg and subActivityCfg.achievements
  if achievements and #achievements > 0 then
    local unfetchCount = 0
    for _, achieveId in ipairs(achievements) do
      local NewTermData = require("Main.NewTerm.data.NewTermData")
      local achieveInfo = NewTermData.Instance():GetAchievementInfo(subActivityCfg.parentActivityId, achieveId)
      if achieveInfo then
        if achieveInfo.state == 2 then
          awardsState = AchieveAwardsState.UNFETCHED
          break
        elseif achieveInfo.state == 1 then
          unfetchCount = unfetchCount + 1
        end
      end
    end
    if awardsState ~= AchieveAwardsState.UNFETCHED then
      if unfetchCount > 0 then
        awardsState = AchieveAwardsState.NONE
      else
        awardsState = AchieveAwardsState.ALL_FETCHED
      end
    end
  end
  return awardsState
end
def.static("number", "=>", "boolean").IsActivityDone = function(activityId)
  local activityCfg = ActivityInterface.GetActivityCfgById(activityId)
  local activityInfo = ActivityInterface.Instance():GetActivityInfo(activityId)
  local curCount = activityInfo and activityInfo.count or 0
  local maxCount = activityCfg and activityCfg.limitCount or 0
  warn(string.format("[NewTermUtils:IsActivityDone] activityId[%d] curCount=%d, maxCount=%d.", activityId, curCount, maxCount))
  return maxCount > 0 and curCount >= maxCount
end
NewTermUtils.Commit()
return NewTermUtils
