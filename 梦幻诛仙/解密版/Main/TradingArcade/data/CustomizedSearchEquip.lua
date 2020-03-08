local MODULE_NAME = (...)
local Lplus = require("Lplus")
local CustomizedSearch = import(".CustomizedSearch")
local CustomizedSearchEquip = Lplus.Extend(CustomizedSearch, MODULE_NAME)
local SearchEquipMgr = require("Main.TradingArcade.SearchEquipMgr")
local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
local SkillUtility = require("Main.Skill.SkillUtility")
local def = CustomizedSearchEquip.define
def.override().Init = function(self)
  self.type = CustomizedSearch.CustomizeType.Equip
end
def.override("=>", "table").GetSearchMgrDelegate = function(self, params)
  return SearchEquipMgr.Instance()
end
def.override("=>", "string").GetDisplayName = function(self)
  return textRes.TradingArcade[217]
end
def.override("=>", "string").GetConditionDesc = function(self)
  local subid = self.condition.subid
  local level = self.condition.level
  local subCfg = TradingArcadeUtils.GetMarketSubTypeCfg(subid)
  local colorText
  local colorNum = table.nums(self.condition.colors)
  if colorNum == 1 then
    local color = next(self.condition.colors)
    colorText = textRes.Item.ColorName[color]
  elseif colorNum == 2 then
    local color = next(self.condition.colors)
    local colorText1 = textRes.Item.ColorName[color]
    local color = next(self.condition.colors, color)
    local colorText2 = textRes.Item.ColorName[color]
    colorText = string.format(textRes.TradingArcade[216], colorText1, colorText2)
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
  table.insert(textTable, subCfg.name)
  table.insert(textTable, string.format(textRes.Common[3], level))
  if colorText then
    table.insert(textTable, colorText)
  end
  if skillName then
    table.insert(textTable, skillName)
  end
  local text = table.concat(textTable, "  ")
  return text
end
return CustomizedSearchEquip.Commit()
