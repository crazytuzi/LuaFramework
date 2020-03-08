local Lplus = require("Lplus")
local WingsPropData = Lplus.Class("WingsPropData")
local def = WingsPropData.define
def.field("number").propType = 0
def.field("number").propValue = 0
def.field("number").propPhase = 0
def.method("table").RawSet = function(self, data)
  self.propType = data.propertyType
  self.propValue = data.propertyValue
  self.propPhase = data.propertyPhase
end
return WingsPropData.Commit()
