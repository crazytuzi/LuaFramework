local Lplus = require("Lplus")
local CrossBattleFightCorpsInfo = Lplus.Class("CrossBattleFightCorpsInfo")
local def = CrossBattleFightCorpsInfo.define
def.field("userdata").corpsId = nil
def.field("number").zoneId = 0
def.field("string").corpsName = ""
def.field("number").corpsIcon = 0
def.method("table").RawSet = function(self, p)
  self.corpsId = p.corps_id
  self.zoneId = p.zone_id
  self.corpsName = _G.GetStringFromOcts(p.corps_name)
  self.corpsIcon = p.corps_icon
end
def.method("=>", "userdata").GetCorpsId = function(self)
  return self.corpsId
end
def.method("=>", "number").GetZoneId = function(self)
  return self.zoneId
end
def.method("=>", "string").GetCorpsName = function(self)
  return self.corpsName
end
def.method("=>", "number").GetCorpsIcon = function(self)
  return self.corpsIcon
end
CrossBattleFightCorpsInfo.Commit()
return CrossBattleFightCorpsInfo
