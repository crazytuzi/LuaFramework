local MODULE_NAME = (...)
local Lplus = require("Lplus")
local TeamPlatformData = require("Main.TeamPlatform.data.TeamPlatformData")
local TeamPlatformActivityData = Lplus.Extend(TeamPlatformData, MODULE_NAME)
local ActivityInterface = require("Main.activity.ActivityInterface")
local TeamPlatformUtils = require("Main.TeamPlatform.TeamPlatformUtils")
local def = TeamPlatformActivityData.define
def.field("table")._activityCfg = nil
def.override("=>", "boolean").IsOpen = function(self)
  local heroLevel = require("Main.Hero.Interface").GetHeroProp().level
  local activityCfg = self:GetActivityCfg()
  local isOpen = heroLevel >= activityCfg.levelMin and heroLevel <= activityCfg.levelMax
  if isOpen and self:IsHaveSubOptions() then
    local subCfg = self:GetSubCfg()
    return subCfg and #subCfg.optionList > 0
  else
    return isOpen
  end
end
def.method("=>", "table").GetActivityCfg = function(self)
  if self._activityCfg == nil then
    self._activityCfg = ActivityInterface.GetActivityCfgById(self.refId)
  end
  return self._activityCfg
end
def.override("=>", "table").GetActiveLevelRange = function(self)
  local activityCfg = self:GetActivityCfg()
  local levelRange = {
    minLevel = activityCfg.levelMin,
    maxLevel = activityCfg.levelMax
  }
  return levelRange
end
return TeamPlatformActivityData.Commit()
