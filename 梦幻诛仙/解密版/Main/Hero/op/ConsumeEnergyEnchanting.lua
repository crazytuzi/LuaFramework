local Lplus = require("Lplus")
local ConsumeEnergy = require("Main.Hero.op.ConsumeEnergy")
local ConsumeEnergyEnchanting = Lplus.Extend(ConsumeEnergy, "ConsumeEnergyEnchanting")
local HeroEnergyMgr = Lplus.ForwardDeclare("HeroEnergyMgr")
local SkillMgr = require("Main.Skill.SkillMgr")
local def = ConsumeEnergyEnchanting.define
def.field("table")._enchantingSkill = nil
def.static("=>", ConsumeEnergyEnchanting).New = function()
  local instance = ConsumeEnergyEnchanting()
  instance:Init()
  return instance
end
def.method().Init = function(self)
  local enchantingSkill = SkillMgr.Instance():GetEnchantingSkill()
  self._enchantingSkill = enchantingSkill
  if not self:IsUnlock() then
    return
  end
  self.opName = textRes.Hero.consumeEnergyEventOP[2]
  local skillCfg = require("Main.Skill.SkillUtility").GetEnchantingSkillCfg(self._enchantingSkill.id)
  local iconId = skillCfg.iconId
  local cost = SkillMgr.Instance():GetFormulaResult(skillCfg.costFormulaId, self._enchantingSkill.level)
  self:AddItem(iconId, cost, textRes.Hero.consumeEnergyEvent[2], self._enchantingSkill.level)
end
def.override("number").OnClick = function(self, selectedIndex)
  local skillBagId, skillId = self._enchantingSkill.bagId, self._enchantingSkill.id
  Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_ENERGY_PANEL_USE_ENCHANTING_SKILL, {skillBagId, skillId})
  print("enchantingSkill ", skillBagId, ", ", skillId)
end
def.override("=>", "boolean").IsUnlock = function(self)
  if self._enchantingSkill == nil then
    return false
  end
  return self._enchantingSkill:IsUnlock()
end
ConsumeEnergyEnchanting.Commit()
return ConsumeEnergyEnchanting
