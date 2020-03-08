local Lplus = require("Lplus")
local SkillData = Lplus.Class("SkillData")
local def = SkillData.define
local NOT_SET = -1
def.field("number").id = NOT_SET
def.field("number").level = NOT_SET
def.field("number").unlockLevel = NOT_SET
def.field("number").bagId = NOT_SET
def.field("boolean").isBasicSkill = false
def.field("boolean").isFaBaoSkill = false
def.method("=>", "boolean").IsUnlock = function(self)
  if self.level >= self.unlockLevel then
    return true
  else
    return false
  end
end
def.method("number").SetLevel = function(self, level)
  local needNotifyUnlock = false
  if self.level < self.unlockLevel and level >= self.unlockLevel then
    needNotifyUnlock = true
  end
  self.level = level
  local notPassiveSkill = not self:IsPassiveSkill()
  if needNotifyUnlock and notPassiveSkill then
    GameUtil.AddGlobalTimer(0, true, function()
      Event.DispatchEvent(ModuleId.SKILL, gmodule.notifyId.Skill.OCCUPATION_SKILL_UNLOCK, {
        self.bagId,
        self.id
      })
    end)
  end
end
def.method("=>", "boolean").IsPassiveSkill = function(self)
  local SkillUtility = require("Main.Skill.SkillUtility")
  return SkillUtility.IsPassiveSkill(self.id)
end
def.method("=>", "boolean").IsEnchantingSkill = function(self)
  local SkillUtility = require("Main.Skill.SkillUtility")
  return SkillUtility.IsEnchantingSkill(self.id)
end
return SkillData.Commit()
