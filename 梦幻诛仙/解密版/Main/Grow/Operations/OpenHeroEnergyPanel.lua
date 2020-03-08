local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenHeroEnergyPanel = Lplus.Extend(Operation, CUR_CLASS_NAME)
local def = OpenHeroEnergyPanel.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.OPEN_ENERGY_PANEL, nil)
  return false
end
return OpenHeroEnergyPanel.Commit()
