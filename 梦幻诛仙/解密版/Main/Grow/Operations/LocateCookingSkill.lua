local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local LocateCookingSkill = Lplus.Extend(Operation, CUR_CLASS_NAME)
local def = LocateCookingSkill.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  local id = 111702000
  Event.DispatchEvent(ModuleId.SKILL, gmodule.notifyId.Skill.LIVING_SKILL_ACCESS, {id})
  return false
end
return LocateCookingSkill.Commit()
