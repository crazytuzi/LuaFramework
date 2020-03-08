local Lplus = require("Lplus")
local EnergySourceData = Lplus.Class("EnergySourceData")
local def = EnergySourceData.define
def.field("number").awardType = 0
def.field("number").awardedTimes = 0
def.field("number").awardedValue = 0
def.field("table").cfg = nil
def.virtual("table").Init = function(self, cfg)
  self.awardType = cfg.awardType
  self.cfg = cfg
end
def.method("=>", "table").GetEnergyDescCfg = function(self)
  return self.cfg
end
def.method("=>", "boolean").IsFull = function(self)
  local cfg = self.cfg
  return self.awardedTimes >= cfg.count
end
def.method("=>", "number").GetRemianCount = function(self)
  return self.cfg.count - self.awardedTimes
end
def.method("=>", "string").GetFullDesc = function(self)
  return string.format(textRes.Hero[25], self.cfg.desc, self.cfg.count)
end
def.virtual("=>", "boolean").GoToGetEnergy = function(self)
  warn("method not implemented type = " .. self.awardType)
  return false
end
EnergySourceData.Commit()
return EnergySourceData
