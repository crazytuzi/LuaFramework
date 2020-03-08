local Lplus = require("Lplus")
local SkillInterface = Lplus.Class("SkillInterface")
local SkillMgr = require("Main.Skill.SkillMgr")
local def = SkillInterface.define
def.static("=>", "table").GetBasicSkillList = function()
  return SkillMgr.Instance():GetBasicSkillList()
end
def.static("=>", "table").GetInFightSkillList = function()
  return SkillMgr.Instance():GetInFightSkillList()
end
def.static("=>", "table").GetOnHookSkillList = function()
  return SkillMgr.Instance():GetOnHookSkillList()
end
return SkillInterface.Commit()
