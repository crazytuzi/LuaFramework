local Lplus = require("Lplus")
local ExerciseSkillBagData = Lplus.Class("ExerciseSkillBagData")
local def = ExerciseSkillBagData.define
local SkillUtility = require("Main.Skill.SkillUtility")
local ExerciseSkillMgr = Lplus.ForwardDeclare("ExerciseSkillMgr")
local NOT_SET = 0
def.field("number").id = NOT_SET
def.field("number").level = -1
def.field("number").exp = NOT_SET
def.field("boolean").isDefault = false
def.field("table")._cfgData = nil
def.field("number")._levelUpNeedExp = NOT_SET
def.field("boolean")._needReCalcExp = false
def.method("table").RawSet = function(self, data)
  self.id = data.skillBagId
  self.exp = data.exp
  if self.level ~= data.skillLevel then
    self.level = data.skillLevel
    self:ReCalcLevelUpNeedExp()
  end
end
def.method("=>", "table").GetCfgData = function(self)
  if self._cfgData == nil then
    self._cfgData = SkillUtility.GetExerciseSkillBagCfg(self.id)
  end
  return self._cfgData
end
def.method("=>", "number").GetLevelUpNeedExp = function(self)
  if self._needReCalcExp then
    local cfgData = self:GetCfgData()
    self._levelUpNeedExp = SkillUtility.GetExerciseSkillLevelUpNeedExp(self.level + 1, cfgData.levelUpCfgId)
    self._needReCalcExp = false
  end
  return self._levelUpNeedExp
end
def.method().ReCalcLevelUpNeedExp = function(self)
  self._needReCalcExp = true
end
def.method("=>", "number").GetMaxLevel = function(self)
  local cfgData = self:GetCfgData()
  return ExerciseSkillMgr.Instance():GetCurSkillBagMaxLevel(cfgData.levelUpCfgId)
end
return ExerciseSkillBagData.Commit()
