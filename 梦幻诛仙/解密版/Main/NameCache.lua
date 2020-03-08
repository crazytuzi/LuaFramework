local Lplus = require("Lplus")
local NameCache = Lplus.Class("NameCache")
local def = NameCache.define
def.field("table").Name = nil
def.field("table").Faction = nil
def.final("=>", NameCache).new = function()
  local obj = NameCache()
  obj.Name = {}
  obj.Faction = {}
  return obj
end
def.method("string", "string").AddPlayerName = function(self, id, name)
  self.Name[id] = name
end
def.method("string", "=>", "string").GetPlayerName = function(self, id)
  return self.Name[id] or ""
end
def.method("number", "string").AddFactionName = function(self, id, name)
  self.Faction[id] = name
end
def.method("number", "=>", "string").GetFactionName = function(self, id)
  return self.Faction[id] or ""
end
NameCache.Commit()
return NameCache
