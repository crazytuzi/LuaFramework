local Lplus = require("Lplus")
local ActivityInterface = require("Main.activity.ActivityInterface")
local CarnivalUtils = Lplus.Class("CarnivalUtils")
local def = CarnivalUtils.define
def.static("number", "table", "boolean", "=>", "boolean").CanAttendActivity = function(activityId, activityCfg, bToast)
  if nil == activityCfg then
    activityCfg = ActivityInterface.GetActivityCfgById(activityId)
  end
  if nil == activityCfg then
    warn("[ERROR][CarnivalUtils:CanAttendActivity] activityCfg nil for id:", activityId)
    return false
  end
  if nil == _G.GetHeroProp() then
    warn("[ERROR][CarnivalUtils:CanAttendActivity] _G.GetHeroProp() nil.")
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
  local bActivityOpen = ActivityInterface.Instance():isActivityOpend(activityCfg.id)
  if false == bActivityOpen then
    if bToast then
      Toast(textRes.Carnival.ACTIVITY_CLOSED)
    end
    return false
  end
  return true
end
def.method("number", "=>", "table").GetAwardItems = function(self, awardId)
  local ItemUtils = require("Main.Item.ItemUtils")
  local SOccupationEnum = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
  local SGenderEnum = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
  local key = string.format("%d_%d_%d", awardId, SOccupationEnum.ALL, SGenderEnum.ALL)
  local cfg = ItemUtils.GetGiftAwardCfg(key)
  local itemList = ItemUtils.GetAwardItemsFromAwardCfg(cfg)
  if itemList and itemList[1] then
    warn(string.format("[CarnivalUtils:GetAwardItems] get awardId[%d] with itemid[%s] num[%d]!", awardId, itemList[1].itemId, itemList[1].num))
    return itemList
  else
    return nil
  end
end
def.static("table", "=>", "boolean").ContainCarnivalActivity = function(activityList)
  local result = false
  local carnivalActivityList = require("Main.Carnival.data.CarnivalData").Instance():GetValidActivities(constant.ActivitiesGuidelineConsts.ACTIVITY_ID)
  if activityList and #activityList > 0 and carnivalActivityList and #carnivalActivityList > 0 then
    for _, activityId in ipairs(activityList) do
      for _, carnivalActCfg in ipairs(carnivalActivityList) do
        if activityId == carnivalActCfg.id then
          result = true
          break
        end
      end
      if result then
        break
      end
    end
  end
  return result
end
CarnivalUtils.Commit()
return CarnivalUtils
