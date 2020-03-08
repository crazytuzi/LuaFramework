local Lplus = require("Lplus")
local EnergySourceData = require("Main.Hero.data.energy.EnergySourceData")
local ActivityEnergySourceData = Lplus.Extend(EnergySourceData, "ActivityEnergySourceData")
local def = ActivityEnergySourceData.define
def.field("number").activityId = 0
def.override("table").Init = function(self, cfg)
  EnergySourceData.Init(self, cfg)
  self.activityId = cfg.param
end
def.override("=>", "boolean").GoToGetEnergy = function(self)
  local ParticipateActivity = require("Main.Grow.Operations.ParticipateActivity")
  return ParticipateActivity():Operate({
    self.activityId
  })
end
ActivityEnergySourceData.Commit()
return ActivityEnergySourceData
