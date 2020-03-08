local Lplus = require("Lplus")
local ConsumeEnergy = require("Main.Hero.op.ConsumeEnergy")
local ConsumeEnergyWorking = Lplus.Extend(ConsumeEnergy, "ConsumeEnergyWorking")
local HeroEnergyMgr = Lplus.ForwardDeclare("HeroEnergyMgr")
local def = ConsumeEnergyWorking.define
def.static("=>", ConsumeEnergyWorking).New = function()
  local instance = ConsumeEnergyWorking()
  instance:Init()
  return instance
end
def.method().Init = function(self)
  if not self:IsUnlock() then
    return
  end
  self.produceItem = false
  self.opName = textRes.Hero.consumeEnergyEventOP[1]
  local HeroUtility = require("Main.Hero.HeroUtility")
  local iconId = HeroUtility.Instance():GetRoleCommonConsts("VIGOR_WORK_ICON") or 0
  local cost = HeroEnergyMgr.Instance():GetEnergyWorkingCost()
  self:AddItem(iconId, cost, textRes.Hero.consumeEnergyEvent[1], -1)
end
def.override("number").OnClick = function(self, selectedIndex)
  print("working..........")
  require("Main.Hero.mgr.HeroEnergyMgr").Instance():EnergyWorking()
end
def.override("=>", "boolean").IsUnlock = function(self)
  return true
end
ConsumeEnergyWorking.Commit()
return ConsumeEnergyWorking
