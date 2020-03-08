local Lplus = require("Lplus")
local EnergySourceData = require("Main.Hero.data.energy.EnergySourceData")
local WaBaoEnergySourceData = Lplus.Extend(EnergySourceData, "WaBaoEnergySourceData")
local def = WaBaoEnergySourceData.define
def.override("=>", "boolean").GoToGetEnergy = function(self)
  return gmodule.moduleMgr:GetModule(ModuleId.WABAO):GotoWabao()
end
WaBaoEnergySourceData.Commit()
return WaBaoEnergySourceData
