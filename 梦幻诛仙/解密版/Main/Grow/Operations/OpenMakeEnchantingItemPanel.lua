local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenMakeEnchantingItemPanel = Lplus.Extend(Operation, CUR_CLASS_NAME)
local def = OpenMakeEnchantingItemPanel.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  Event.DispatchEvent(ModuleId.SKILL, gmodule.notifyId.Skill.SELECT_ENCHANTING_SKILL, {0})
  return false
end
return OpenMakeEnchantingItemPanel.Commit()
