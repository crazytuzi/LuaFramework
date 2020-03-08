local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local SkillUIMgr = Lplus.Class("SkillUIMgr")
local def = SkillUIMgr.define
local UISet = {SkillPanel = "SkillPanel"}
def.const("table").UISet = UISet
def.const("table").SkillPanelNodeId = {
  OccupationSkillNode = 1,
  ExerciseSkillNode = 2,
  LivingSkillNode = 3,
  OtherSkillNode = 4
}
def.field("string").modulePrefix = ""
local instance
def.static("=>", SkillUIMgr).Instance = function()
  if instance == nil then
    instance = SkillUIMgr()
  end
  return instance
end
def.method().Init = function(self)
  self:InitModulePrefix()
  Event.RegisterEvent(ModuleId.SKILL, gmodule.notifyId.Skill.REQ_OPEN_SKILL_PANEL, SkillUIMgr.OnReqOpenSkillPanel)
  Event.RegisterEvent(ModuleId.SKILL, gmodule.notifyId.Skill.EXERCISE_SKILL_LEVEL_UP, SkillUIMgr.OnExerciseSkillLevelUp)
  Event.RegisterEvent(ModuleId.SKILL, gmodule.notifyId.Skill.OCCUPATION_SKILL_BAG_LEVEL_UP_SUCCESS, SkillUIMgr.OnOccupationSkillBagLevelUp)
end
def.method().InitModulePrefix = function(self)
  local sPos, ePos = string.find(MODULE_NAME, ".[%w_]+$")
  self.modulePrefix = string.sub(MODULE_NAME, 1, sPos - 1)
end
def.method("string", "=>", "table").GetUI = function(self, uiName)
  return require(self.modulePrefix .. ".ui." .. uiName)
end
def.static("table", "table").OnReqOpenSkillPanel = function(params)
  local self = instance
  local skillFuncType = params[1]
  self:GetUI(UISet.SkillPanel).Instance():SetCurNode(skillFuncType)
  self:GetUI(UISet.SkillPanel).Instance():ShowPanel(skillFuncType)
end
def.static("table", "table").OnExerciseSkillLevelUp = function(params)
  local skillBagId, lastlevel, curlevel = unpack(params)
  local skillBag = require("Main.Skill.ExerciseSkillMgr").Instance():GetSkillBag(skillBagId)
  local skillName = skillBag:GetCfgData().skillCfg.name
  local skillLevel = curlevel
  local text = string.format(textRes.Skill[21], skillName, skillLevel)
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  PersonalHelper.CommonTableMsg({
    {
      PersonalHelper.Type.Text,
      text
    }
  })
end
local enchantingSkillNotifyLevel
def.static("table", "table").OnOccupationSkillBagLevelUp = function(params)
  local skillBagId, _, lastLevel = unpack(params)
  local SkillMgr = require("Main.Skill.SkillMgr")
  local skillBag = SkillMgr.Instance():GetOccupationSkillBag(skillBagId)
  if skillBag == nil then
    return
  end
  if enchantingSkillNotifyLevel == nil then
    local SkillUtility = require("Main.Skill.SkillUtility")
    enchantingSkillNotifyLevel = SkillUtility.GetSkillConsts("FUMO_SKILL_GUIDE")
  end
  if lastLevel < enchantingSkillNotifyLevel and skillBag.level >= enchantingSkillNotifyLevel then
    local encSkill = SkillMgr.Instance():GetEnchantingSkill()
    if encSkill and encSkill.bagId == skillBag.id then
      require("Main.Skill.SkillMgr").Instance():SetEnchantingSkillNotify(true)
    end
  end
end
return SkillUIMgr.Commit()
