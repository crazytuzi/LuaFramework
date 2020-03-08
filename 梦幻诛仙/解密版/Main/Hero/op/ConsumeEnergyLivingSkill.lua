local Lplus = require("Lplus")
local ConsumeEnergy = require("Main.Hero.op.ConsumeEnergy")
local ConsumeEnergyLivingSkill = Lplus.Extend(ConsumeEnergy, "ConsumeEnergyLivingSkill")
local HeroEnergyMgr = Lplus.ForwardDeclare("HeroEnergyMgr")
local def = ConsumeEnergyLivingSkill.define
local LifeSkillBagShowTypeEnum = require("consts.mzm.gsp.skill.confbean.LifeSkillBagShowTypeEnum")
local LivingSkillData = require("Main.Skill.data.LivingSkillData")
local ItemUtils = require("Main.Item.ItemUtils")
def.field("table")._skillBag = nil
def.field("table")._itemList = nil
def.static("table", "=>", ConsumeEnergyLivingSkill).New = function(skillBag)
  local instance = ConsumeEnergyLivingSkill()
  instance:Init(skillBag)
  return instance
end
def.method("table").Init = function(self, skillBag)
  self._skillBag = skillBag
  if not self:IsUnlock() then
    return
  end
  self._itemList = {}
  self.opName = textRes.Skill.LivingSkillBagShowType[skillBag.showType]
  local iconId = skillBag.iconId
  local LivingSkillUtility = require("Main.Skill.LivingSkillUtility")
  if skillBag.showType == LifeSkillBagShowTypeEnum.type1 then
    local skillList = LivingSkillData.Instance():GetUnLockSkill(skillBag.id)
    for i, v in ipairs(skillBag.itemIdList) do
      if v.openLevel > skillBag.level then
        self.selectedIndex = i - 1
        break
      end
      local itemBase = ItemUtils.GetItemBase(v.id)
      local cost = LivingSkillUtility.GetCostVigor(skillBag.id, v.openLevel)
      self:AddItem(itemBase.icon, cost, itemBase.name, v.openLevel)
      table.insert(self._itemList, v.id)
    end
  else
    local cost = LivingSkillUtility.GetCostVigor(skillBag.id, skillBag.level)
    self:AddItem(iconId, cost, skillBag.name, skillBag.level)
  end
end
def.override("number").OnClick = function(self, selectedIndex)
  local skillBagId = self._skillBag.id
  local itemId = self._itemList[selectedIndex] or 0
  Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_ENERGY_PANEL_USE_LIVING_SKILL, {skillBagId, itemId})
end
def.override("=>", "boolean").IsUnlock = function(self)
  local skillBag = self._skillBag
  for i, v in ipairs(skillBag.itemIdList) do
    if v.openLevel <= skillBag.level then
      return true
    end
  end
  return false
end
ConsumeEnergyLivingSkill.Commit()
return ConsumeEnergyLivingSkill
