local MODULE_NAME = (...)
local Lplus = require("Lplus")
local TeamPlatformData = Lplus.Class(MODULE_NAME)
local TeamPlatformUtils = require("Main.TeamPlatform.TeamPlatformUtils")
local HeroUtility = require("Main.Hero.HeroUtility")
local def = TeamPlatformData.define
def.field("number").id = 0
def.field("number").cfgId = 0
def.field("number").refId = 0
def.field("number").aidNewbieCapacity = 0
def.field("number").matchType = 0
def.field("number").classId = 0
def.field("string").name = ""
def.field("string").instruction = ""
def.field("boolean").canAIMatch = false
def.virtual("=>", "boolean").IsOpen = function(self)
  if self:IsHaveSubOptions() then
    local subCfg = self:GetSubCfg()
    return subCfg and #subCfg.optionList > 0
  else
    return true
  end
end
def.virtual("=>", "table").GetActiveLevelRange = function(self)
  local maxLevel = HeroUtility.Instance():GetRoleCommonConsts("MAX_LEVEL")
  local levelRange = {minLevel = 0, maxLevel = maxLevel}
  if self:IsHaveSubOptions() then
    local subCfgList = TeamPlatformUtils.GetTeamPlatformMatchOptionSubCfg(self.cfgId)
    if subCfgList and 0 < #subCfgList.optionList then
      levelRange.minLevel = subCfgList.optionList[1].minLevel
      levelRange.maxLevel = subCfgList.optionList[#subCfgList.optionList].maxLevel
    end
  end
  return levelRange
end
def.virtual("=>", "string").GetName = function(self)
  return self.name
end
def.method("=>", "table").GetSubCfg = function(self)
  if self.cfgId == 0 then
    return nil
  end
  local subCfgList = TeamPlatformUtils.GetTeamPlatformMatchOptionSubCfg(self.cfgId)
  local heroLevel = require("Main.Hero.Interface").GetHeroProp().level
  local openedOptionList = {}
  for i, option in ipairs(subCfgList.optionList) do
    if heroLevel >= option.minLevel then
      table.insert(openedOptionList, option)
    end
  end
  subCfgList.optionList = openedOptionList
  return subCfgList
end
def.method("=>", "boolean").IsHaveSubOptions = function(self)
  return self.cfgId ~= 0
end
def.method("=>", "boolean").IsAidNewbieAvilable = function(self)
  if self.aidNewbieCapacity <= 0 then
    return false
  end
  return _G.GetHeroProp().level >= TeamPlatformUtils.GetTeamPlatformConsts("SLECET_NEW__LEVEL")
end
return TeamPlatformData.Commit()
