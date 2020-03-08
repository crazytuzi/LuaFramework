local Lplus = require("Lplus")
local NPCServiceNameModifier = Lplus.Class("NPCServiceNameModifier")
local NPCInterface = require("Main.npc.NPCInterface")
local def = NPCServiceNameModifier.define
local instance
def.static("=>", NPCServiceNameModifier).Instance = function()
  if instance == nil then
    instance = NPCServiceNameModifier()
    instance:Init()
  end
  return instance
end
def.field("table")._fnTable = nil
def.method().Init = function(self)
  self._fnTable = {}
end
def.method("number", "function").RegisterServiceNameModifier = function(self, serviceID, fn)
  self._fnTable[serviceID] = fn
end
def.method("table", "table", "=>", "string").GetServiceName = function(self, serviceCfg, param)
  local fn = self._fnTable[serviceCfg.serviceID]
  if fn ~= nil then
    local ret = fn(serviceCfg, param)
    return ret
  end
  return serviceCfg.choiceName
end
NPCServiceNameModifier.Commit()
return NPCServiceNameModifier
