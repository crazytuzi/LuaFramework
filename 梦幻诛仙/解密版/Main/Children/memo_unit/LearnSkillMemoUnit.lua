local MODULE_NAME = (...)
local Lplus = require("Lplus")
local BaseMemoUnit = import(".BaseMemoUnit")
local LearnSkillMemoUnit = Lplus.Extend(BaseMemoUnit, MODULE_NAME)
local GrowthSubType = require("netio.protocol.mzm.gsp.children.GrowthSubType")
local def = LearnSkillMemoUnit.define
def.field("number").m_oldSkillId = 0
def.field("number").m_newSkillId = 0
def.override("number", "userdata", "table").Init = function(self, type, occurtime, params)
  BaseMemoUnit.Init(self, type, occurtime, params)
  self.m_oldSkillId = self.m_intParams[GrowthSubType.ADULT_STUDY_SKILL_ORIGINAL] or 0
  self.m_newSkillId = self.m_intParams[GrowthSubType.ADULT_STUDY_SKILL_NOW] or 0
end
def.override("=>", "string").GetFormattedText = function(self)
  if self.m_newSkillId <= 0 then
    return "error skill id\239\188\154" .. self.m_menpai
  end
  local SkillUtility = require("Main.Skill.SkillUtility")
  local newSkill = SkillUtility.GetSkillCfg(self.m_newSkillId)
  local txt = ""
  if 0 >= self.m_oldSkillId then
    txt = string.format(textRes.Children[3066], newSkill.name)
  else
    local oldSkill = SkillUtility.GetSkillCfg(self.m_oldSkillId)
    txt = string.format(textRes.Children[3067], newSkill.name, oldSkill.name)
  end
  return txt
end
return LearnSkillMemoUnit.Commit()
