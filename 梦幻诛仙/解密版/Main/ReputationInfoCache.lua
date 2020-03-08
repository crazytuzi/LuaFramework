local Lplus = require("Lplus")
local ReputationCache = Lplus.Class("ReputationCache")
local def = ReputationCache.define
def.field("table").Reputation = nil
def.final("=>", ReputationCache).new = function()
  local obj = ReputationCache()
  obj.Reputation = {}
  return obj
end
def.method("string", "table").AddPlayerReputation = function(self, id, reputation)
  self.Reputation[id] = reputation
end
def.method("string", "=>", "table").GetPlayerReputation = function(self, id)
  return self.Reputation[id] or {}
end
ReputationCache.Commit()
return ReputationCache
