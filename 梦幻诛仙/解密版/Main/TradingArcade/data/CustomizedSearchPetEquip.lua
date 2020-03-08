local MODULE_NAME = (...)
local Lplus = require("Lplus")
local CustomizedSearch = import(".CustomizedSearch")
local CustomizedSearchPetEquip = Lplus.Extend(CustomizedSearch, MODULE_NAME)
local SearchPetEquipMgr = require("Main.TradingArcade.SearchPetEquipMgr")
local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
local SkillUtility = require("Main.Skill.SkillUtility")
local def = CustomizedSearchPetEquip.define
def.override().Init = function(self)
  self.type = CustomizedSearch.CustomizeType.PetEquip
end
def.override("=>", "table").GetSearchMgrDelegate = function(self, params)
  return SearchPetEquipMgr.Instance()
end
def.override("=>", "string").GetDisplayName = function(self)
  return textRes.TradingArcade[219]
end
def.override("=>", "string").GetConditionDesc = function(self)
  local subid = self.condition.subid
  local level = self.condition.level
  local subCfg = TradingArcadeUtils.GetMarketSubTypeCfg(subid)
  local textTable = {}
  local periodStateName = self:GetPeriodStateName()
  if periodStateName ~= "" then
    table.insert(textTable, periodStateName)
  end
  table.insert(textTable, subCfg.name)
  for skillId, v in pairs(self.condition.skillIds) do
    local skillCfg = SkillUtility.GetSkillCfg(skillId)
    local skillName = skillCfg and skillCfg.name or ""
    table.insert(textTable, skillName)
  end
  local text = table.concat(textTable, "  ")
  return text
end
return CustomizedSearchPetEquip.Commit()
