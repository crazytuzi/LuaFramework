local MODULE_NAME = (...)
local Lplus = require("Lplus")
local CustomizedSearch = import(".CustomizedSearch")
local CustomizedSearchPet = Lplus.Extend(CustomizedSearch, MODULE_NAME)
local SearchPetMgr = require("Main.TradingArcade.SearchPetMgr")
local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
local SkillUtility = require("Main.Skill.SkillUtility")
local def = CustomizedSearchPet.define
def.override().Init = function(self)
  self.type = CustomizedSearch.CustomizeType.Pet
end
def.override("=>", "table").GetSearchMgrDelegate = function(self, params)
  return SearchPetMgr.Instance()
end
def.override("=>", "string").GetDisplayName = function(self)
  return textRes.TradingArcade[218]
end
def.override("=>", "string").GetConditionDesc = function(self)
  local subid = self.condition.subid
  local SearchPetMgr = require("Main.TradingArcade.SearchPetMgr")
  local defaults = SearchPetMgr.Instance():GetDefaultValues(subid)
  local subCfg = TradingArcadeUtils.GetMarketSubTypeCfg(subid)
  local petTypeText
  local colorNum = table.nums(self.condition.petTypes)
  if colorNum == 1 then
    local petType = next(self.condition.petTypes)
    petTypeText = textRes.Pet.Type[petType]
  elseif colorNum == 2 then
    local petType = next(self.condition.petTypes)
    local petTypeText1 = textRes.Pet.Type[petType]
    local petType = next(self.condition.petTypes, petType)
    local petTypeText2 = textRes.Pet.Type[petType]
    petTypeText = string.format(textRes.TradingArcade[216], petTypeText1, petTypeText2)
  end
  local skillId = next(self.condition.skillIds)
  local skillName
  if skillId then
    local skillCfg = SkillUtility.GetSkillCfg(skillId)
    skillName = skillCfg and skillCfg.name or nil
  end
  local textTable = {}
  local periodStateName = self:GetPeriodStateName()
  if periodStateName ~= "" then
    table.insert(textTable, periodStateName)
  end
  table.insert(textTable, defaults.level.name)
  table.insert(textTable, defaults.pet.petCfg.templateName)
  if petTypeText then
    table.insert(textTable, petTypeText)
  end
  local skillNumText = string.format(textRes.TradingArcade[231], self.condition.skillNum)
  table.insert(textTable, skillNumText)
  if skillName then
    table.insert(textTable, skillName)
  end
  local text = table.concat(textTable, "  ")
  return text
end
return CustomizedSearchPet.Commit()
