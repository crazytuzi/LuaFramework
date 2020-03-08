local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local AircraftInfo = Lplus.Class(CUR_CLASS_NAME)
local def = AircraftInfo.define
def.field("number").cfgId = 0
def.field("number").colorId = 0
def.final("number", "number", "=>", AircraftInfo).New = function(cfgId, colorId)
  local AircraftInfo = AircraftInfo()
  AircraftInfo.cfgId = cfgId
  AircraftInfo.colorId = colorId
  return AircraftInfo
end
def.method("number").Dye = function(self, colorId)
  self.colorId = colorId
end
return AircraftInfo.Commit()
