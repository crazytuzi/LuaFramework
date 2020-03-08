local Lplus = require("Lplus")
local EquipInfoCache = Lplus.Class("EquipInfoCache")
local def = EquipInfoCache.define
def.field("table").EquipInfo = nil
def.final("=>", EquipInfoCache).new = function()
  local obj = EquipInfoCache()
  obj.EquipInfo = {}
  return obj
end
def.method("string", "table").AddPlayerEquipInfo = function(self, id, equipInfo)
  self.EquipInfo[id] = equipInfo
end
def.method("string", "=>", "table").GetPlayerEquipInfo = function(self, id)
  return self.EquipInfo[id]
end
EquipInfoCache.Commit()
return EquipInfoCache
