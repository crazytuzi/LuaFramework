local Lplus = require("Lplus")
local SkillBagData = Lplus.Class("SkillBagData")
local def = SkillBagData.define
local SkillBagCfgData = Lplus.ForwardDeclare("SkillBagCfgData")
local SkillData = require("Main.Skill.data.SkillData")
local SkillUtility = require("Main.Skill.SkillUtility")
local NOT_SET = -1
def.field("number").id = NOT_SET
def.field("number").level = NOT_SET
def.field(SkillBagCfgData)._cfgData = nil
def.field("table")._skillList = nil
def.field("table")._activeSkillList = nil
def.method("table").RawSet = function(self, data)
  self.id = data.skillbagid
  self.level = data.level
  if self._skillList then
    for i, skillData in ipairs(self._skillList) do
      skillData:SetLevel(self.level)
    end
  end
end
def.method("=>", "table").GetCfgData = function(self)
  if nil == self._cfgData then
    local SkillUtility = require("Main.Skill.SkillUtility")
    self._cfgData = SkillUtility.GetSkillBagCfg(self.id)
  end
  return self._cfgData
end
def.method("=>", "table").GetSkillList = function(self)
  if self._skillList then
    return self._skillList
  end
  local list = {}
  local cfgData = self:GetCfgData()
  for i, skill in ipairs(cfgData.skillList) do
    local skillData = SkillData()
    skillData.id = skill.id
    skillData.level = self.level
    skillData.unlockLevel = skill.unlockLevel
    skillData.bagId = self.id
    table.insert(list, skillData)
  end
  self._skillList = list
  return list
end
def.method("=>", "table").GetActiveSkillList = function(self)
  if self._activeSkillList then
    return self._activeSkillList
  end
  local skillList = self:GetSkillList()
  local activeSkillList = {}
  for i, skill in ipairs(skillList) do
    if not skill:IsPassiveSkill() then
      table.insert(activeSkillList, skill)
    end
  end
  self._activeSkillList = activeSkillList
  return activeSkillList
end
def.method("=>", "table").GetPassiveSkill = function(self)
  local skillList = self:GetSkillList()
  for i, skill in ipairs(skillList) do
    if skill:IsPassiveSkill() then
      return skill
    end
  end
  return nil
end
return SkillBagData.Commit()
