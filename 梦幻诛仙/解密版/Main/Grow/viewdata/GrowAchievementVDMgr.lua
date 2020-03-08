local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local GrowAchievementVDMgr = Lplus.Class(MODULE_NAME)
local GrowAchievementMgr = import("..GrowAchievementMgr")
local GrowUtils = import("..GrowUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local def = GrowAchievementVDMgr.define
local instance
def.static("=>", GrowAchievementVDMgr).Instance = function()
  if instance == nil then
    instance = GrowAchievementVDMgr()
  end
  return instance
end
def.method("=>", "table").GetTabListViewData = function(self)
  local heroLevel = _G.GetHeroProp().level
  local levelRanges = GrowAchievementMgr.Instance():GetAvailableLevelRanges()
  local viewData = {}
  for i, levelRange in ipairs(levelRanges) do
    local v = {levelRange = levelRange}
    v.name = string.format(textRes.Grow.Achievement[1], levelRange.from, levelRange.to)
    if heroLevel >= levelRange.from and heroLevel <= levelRange.to then
      levelRange.isHeroIn = true
    end
    local achievements = GrowAchievementMgr.Instance():GetAchievementsInLevelRange(levelRange.from, levelRange.to)
    table.insert(viewData, v)
  end
  return viewData
end
def.method("table", "=>", "boolean").HasCanDrawAchievementAward = function(self, levelRange)
  local LevelGuideInfo = require("netio.protocol.mzm.gsp.grow.LevelGuideInfo")
  local achievements = GrowAchievementMgr.Instance():GetAchievementsInLevelRange(levelRange.from, levelRange.to)
  for i, achievement in ipairs(achievements) do
    if achievement.state == LevelGuideInfo.ST_FINISHED then
      return true
    end
  end
  return false
end
def.method("table", "=>", "table").GetListViewData = function(self, levelRange)
  local achievements = GrowAchievementMgr.Instance():GetAchievementsInLevelRange(levelRange.from, levelRange.to)
  local viewData = {}
  local LevelGuideInfo = require("netio.protocol.mzm.gsp.grow.LevelGuideInfo")
  viewData.StateEnum = LevelGuideInfo
  for i, achievement in ipairs(achievements) do
    local v = self:GrowAchievementToViewData(achievement)
    table.insert(viewData, v)
  end
  table.sort(viewData, function(left, right)
    if left.state == LevelGuideInfo.ST_FINISHED and right.state ~= LevelGuideInfo.ST_FINISHED then
      return true
    elseif right.state == LevelGuideInfo.ST_FINISHED and left.state ~= LevelGuideInfo.ST_FINISHED then
      return false
    elseif left.state == LevelGuideInfo.ST_ON_GOING and right.state ~= LevelGuideInfo.ST_ON_GOING then
      return true
    elseif right.state == LevelGuideInfo.ST_ON_GOING and left.state ~= LevelGuideInfo.ST_ON_GOING then
      return false
    else
      return left.rank < right.rank
    end
  end)
  return viewData
end
def.method("number", "=>", "table").GetGrowAchievementViewData = function(self, achievementId)
  local achievement = GrowAchievementMgr.Instance():GetAchievement(achievementId)
  return self:GrowAchievementToViewData(achievement)
end
def.method("table", "=>", "table").GrowAchievementToViewData = function(self, achievement)
  local viewData = {
    id = achievement.id,
    icon = achievement.iconId,
    name = achievement.name,
    desc = achievement.description,
    state = achievement.state,
    rank = achievement.rank
  }
  return viewData
end
return GrowAchievementVDMgr.Commit()
