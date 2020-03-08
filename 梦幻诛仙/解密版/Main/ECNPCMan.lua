local Lplus = require("Lplus")
local ECManager = require("Main.ECManager")
local ECNPC = require("NPCs.ECNPC")
local ECPlayerNPC = require("NPCs.ECPlayerNPC")
local npc_core_info = require("S2C.npc_core_info")
local player_definite_info_data = require("S2C.player_definite_info_data")
local Exptypes = require("Data.Exptypes")
local ECMonsterNPC = require("NPCs.ECMonsterNPC")
local ECServerNPC = require("NPCs.ECServerNPC")
local ECPanelMidmap = require("GUI.ECPanelMidmap")
local ECObject = require("Object.ECObject")
local ECGame = Lplus.ForwardDeclare("ECGame")
local NPCCreationEvents = require("Event.NPCCreationEvents")
local ECNPCMan = Lplus.Extend(ECManager, "ECNPCMan")
local def = ECNPCMan.define
def.field("userdata").NPCRoot = nil
def.field("number").m_UpdateInterval = 0
def.final("=>", ECNPCMan).new = function()
  local obj = ECNPCMan()
  obj:Init(ECManager.EC_MAN_ENUM.MAN_NPC)
  obj.NPCRoot = GameObject.GameObject("NPCs")
  return obj
end
local npc_ess = Exptypes.DATA_TYPE.DT_NPC_ESSENCE
local monster_ess = Exptypes.DATA_TYPE.DT_MONSTER_ESSENCE
local monster_class = ECObject.OBJECT_CLASS.OCID_MONSTER
def.method(npc_core_info, player_definite_info_data, "boolean").CreateNPC = function(self, info, playerinfo, bBornInSight)
  local npc
  if info then
    local datatype = elementdata.get_data_type(info.tid, Exptypes.ID_SPACE.ESSENCE)
    local vb
    if datatype == monster_ess then
      npc = ECMonsterNPC.new()
      vb = false
    elseif datatype == npc_ess then
      npc = ECServerNPC.new()
      vb = true
    else
      warn("CreateNPC, wrong tid ", info.tid)
      return
    end
    npc:Init(info)
    npc:Load(vb)
    self.m_ObjMap[info.id] = npc
    ECGame.EventManager:raiseEvent(nil, NPCCreationEvents.NPCCreateEvent.new(npc))
  elseif playerinfo then
    npc = ECPlayerNPC.new()
    npc:InitInfo(playerinfo)
    self.m_ObjMap[playerinfo.id] = npc
  end
end
def.override("string", "boolean").OnCmd_ObjectLeaveScene = function(self, id, outofsight)
  local npc = self.m_ObjMap[id]
  if npc then
    ECGame.EventManager:raiseEvent(nil, NPCCreationEvents.NPCPreDestroyEvent.new(npc))
  end
  ECManager.OnCmd_ObjectLeaveScene(self, id, outofsight)
  local inst = ECPanelMidmap.Instance()
  inst:RemoveNPCMark(id)
end
def.method().UpdateMidmapMarks = function(self)
  local inst = ECPanelMidmap.Instance()
  local objmap = self.m_ObjMap
  for k, v in pairs(objmap) do
    if v.m_bReady then
      local m = v.m_RootObj
      local pos = m.position
      if v:GetClassID() == monster_class then
        inst:UpdateMonsterMark(k, pos.x, pos.z)
      else
        inst:UpdateNPCMark(k, pos.x, pos.z)
      end
    end
  end
end
def.method().UpdateNPCMidmapMarks = function(self)
  local inst = ECPanelMidmap.Instance()
  local objmap = self.m_ObjMap
  for k, v in pairs(objmap) do
    if v.m_bReady then
      local m = v.m_RootObj
      local pos = m.position
      if v:GetClassID() ~= monster_class then
        inst:UpdateNPCMark(k, pos.x, pos.z)
      end
    end
  end
end
def.method().UpdateMonsterMidmapMarks = function(self)
  local inst = ECPanelMidmap.Instance()
  local objmap = self.m_ObjMap
  for k, v in pairs(objmap) do
    if v.m_bReady then
      local m = v.m_RootObj
      local pos = m.position
      if v:GetClassID() == monster_class then
        inst:UpdateMonsterMark(k, pos.x, pos.z)
      end
    end
  end
end
def.method("string", "=>", ECNPC).GetNPC = function(self, id)
  return self.m_ObjMap[id]
end
def.method("number", "=>", ECNPC).FindNearestNPCByTid = function(self, tid)
  for _, id in ipairs(self.m_SortList) do
    local npc = self:GetNPC(id)
    if npc and npc.InfoData.Tid == tid then
      return npc
    end
  end
  return nil
end
def.method("=>", "varlist").EachNPC = function(self)
  return pairs(self.m_ObjMap)
end
def.method().Update = function(self)
  local ls = self:SortByDistToHost()
  self:UpdateVisible(ls)
end
local _monster_classid = ECObject.OBJECT_CLASS.OCID_MONSTER
def.method("table").UpdateVisible = function(self, ls)
  local hp = ECGame.Instance().m_HostPlayer
  local objmap = self.m_ObjMap
  local target = hp.TargetID
  if target ~= ZeroUInt64 then
    target = objmap[target]
  else
    target = nil
  end
  local vcount = 0
  for k, v in ipairs(ls) do
    if v == target then
      v:SetCullingVisible(true, false)
    elseif v:GetClassID() == _monster_classid then
      if vcount < max_visible_monster then
        v:SetCullingVisible(true, false)
        vcount = vcount + 1
      else
        v:SetCullingVisible(false, false)
      end
    end
  end
end
def.override("boolean").Release = function(self, bReleaseScene)
  ECManager.Release(self, bReleaseScene)
  if bReleaseScene then
    Object.Destroy(self.NPCRoot)
    self.NPCRoot = nil
  end
end
ECNPCMan.Commit()
return ECNPCMan
