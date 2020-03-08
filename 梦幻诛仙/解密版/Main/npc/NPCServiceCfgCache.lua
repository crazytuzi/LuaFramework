local Lplus = require("Lplus")
local DataCache = require("Utility.DataCacheBase")
local NPCServiceCfgCache = Lplus.Extend(DataCache, "NPCServiceCfgCache")
local def = NPCServiceCfgCache.define
def.static("number", "=>", NPCServiceCfgCache).New = function(size)
  local n = NPCServiceCfgCache()
  n:Init()
  n._maxSize = size
  return n
end
def.override("number", "=>", "table")._GetData = function(self, serviceID)
  local NPCInterface = require("Main.npc.NPCInterface")
  local serviceCfg = NPCInterface._LoadNpcServiceCfg(serviceID)
  return serviceCfg
end
def.override("table", "=>", "number")._GetDataKey = function(self, serviceCfg)
  return serviceCfg.serviceID
end
NPCServiceCfgCache.Commit()
return NPCServiceCfgCache
