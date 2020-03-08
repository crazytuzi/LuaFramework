local Lplus = require("Lplus")
local MiniMapMgr = Lplus.Class("MiniMapMgr")
local MapUtility = require("Main.Map.MapUtility")
local def = MiniMapMgr.define
local instance
def.static("=>", MiniMapMgr).Instance = function()
  if instance == nil then
    instance = MiniMapMgr()
  end
  return instance
end
def.field("table").m_hiddenNpcs = nil
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.SET_NPC_ENABLE, MiniMapMgr.OnNpcShow)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, MiniMapMgr.OnLeaveWorld)
  require("Main.Map.minimap.BattlefieldMiniMapMgr").Instance():Init()
end
def.method("number", "=>", "table").GetMiniMapNPCs = function(self, mapId)
  local npcs = {}
  local npcList = MapUtility.GetMiniMapNPC(mapId)
  for i, npcId in ipairs(npcList) do
    if not self:IsNPCHidden(npcId) then
      npcs[#npcs + 1] = npcId
    end
  end
  return npcs
end
def.method("number", "=>", "boolean").IsNPCHidden = function(self, npcId)
  if self.m_hiddenNpcs == nil then
    return false
  end
  return self.m_hiddenNpcs[npcId] ~= nil
end
def.method("number").ShowNPC = function(self, npcId)
  if self.m_hiddenNpcs == nil then
    return
  end
  if self.m_hiddenNpcs[npcId] then
    self.m_hiddenNpcs[npcId] = nil
    Event.DispatchEvent(ModuleId.MAP, gmodule.notifyId.Map.MINI_MAP_NPC_CHANGED, {npcId = npcId, show = true})
  end
end
def.method("number").HideNPC = function(self, npcId)
  self.m_hiddenNpcs = self.m_hiddenNpcs or {}
  self.m_hiddenNpcs[npcId] = true
  Event.DispatchEvent(ModuleId.MAP, gmodule.notifyId.Map.MINI_MAP_NPC_CHANGED, {npcId = npcId, show = false})
end
def.method().Reset = function(self)
  self.m_hiddenNpcs = nil
end
def.static("table", "table").OnNpcShow = function(params)
  local npcId = params.npcid
  if npcId == nil then
    return
  end
  local isShow = params.show
  if isShow then
    instance:ShowNPC(npcId)
  else
    instance:HideNPC(npcId)
  end
end
def.static("table", "table").OnLeaveWorld = function(params)
  instance:Reset()
end
return MiniMapMgr.Commit()
