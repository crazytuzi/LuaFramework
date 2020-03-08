local Lplus = require("Lplus")
local DataCacheBase = require("Utility.DataCacheBase")
local NPCCfgCache = Lplus.Extend(DataCacheBase, "NPCCfgCache")
local def = NPCCfgCache.define
def.static("number", "=>", NPCCfgCache).New = function(size)
  local n = NPCCfgCache()
  n:Init()
  n._maxSize = size
  return n
end
def.override("number", "=>", "table")._GetData = function(self, NPCID)
  local NPCInterface = require("Main.npc.NPCInterface")
  local npcCfg = NPCInterface._LoadNPCCfg(NPCID)
  return npcCfg
end
def.override("table", "=>", "number")._GetDataKey = function(self, npcCfg)
  return npcCfg.NpcID
end
NPCCfgCache.Commit()
return NPCCfgCache
