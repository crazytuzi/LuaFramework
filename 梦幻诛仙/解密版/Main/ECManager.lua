local Lplus = require("Lplus")
local ECObject = require("Object.ECObject")
local ECManager = Lplus.Class("ECManager")
local def = ECManager.define
def.const("table").EC_MAN_ENUM = {
  MAN_PLAYER = 1,
  MAN_NPC = 2,
  MAN_MATTER = 3,
  MAN_SUBOBJECT = 4
}
def.field("number").m_Type = 0
def.field("table").m_ObjMap = nil
def.field("table").m_SortList = nil
def.field("userdata").m_Qteobj = nil
def.field(ECObject).m_objQTE = nil
def.method("number").Init = function(self, type)
  self.m_Type = type
  self.m_ObjMap = {}
  self.m_SortList = {}
end
def.method("=>", "number").GetObjCount = function(self)
  local count = 0
  local objmap = self.m_ObjMap
  for k, v in pairs(objmap) do
    count = count + 1
  end
  return count
end
def.virtual(ECObject).OnObjectLeave = function(self, obj)
end
def.virtual("string", "boolean").OnCmd_ObjectLeaveScene = function(self, id, outofsight)
  local objmap = self.m_ObjMap
  local obj = objmap[id]
  if obj then
    objmap[id] = nil
    self:OnObjectLeave(obj)
    obj:Release()
  end
end
def.method().ReleaseObjAfterQte = function(self)
  if self.m_Qteobj and self.m_objQTE then
    local m = self.m_objQTE.m_ECModel
    m:Play(AnimationNameTable.NPC_Die)
    local ECGame = require("Main.ECGame")
    local cur_target_id = ECGame.Instance().m_HostPlayer.TargetID
    if cur_target_id == self.m_objQTE.ID then
      local TargetChangeEvent = require("Event.TargetChangeEvent")
      local event = TargetChangeEvent()
      event.TargetID = ZeroUInt64
      ECGame.EventManager:raiseEvent(nil, event)
    end
    self.m_objQTE:Release()
    self.m_objQTE = nil
    self.m_Qteobj = nil
  end
end
def.virtual("boolean").Release = function(self, bReleaseScene)
  local objmap = self.m_ObjMap
  for k, v in pairs(objmap) do
    v:Release()
  end
  self.m_ObjMap = {}
end
def.method("=>", "table").SortByDistToHost = function(self)
  local ls = {}
  local objmap = self.m_ObjMap
  for k, v in pairs(objmap) do
    if v.m_bReady then
      ls[#ls + 1] = v
    end
  end
  local mycmp = function(v1, v2)
    return v1:GetDistToHost() < v2:GetDistToHost()
  end
  table.sort(ls, mycmp)
  local idls = {}
  for i = 1, #ls do
    idls[i] = ls[i].ID
  end
  self.m_SortList = idls
  return ls
end
def.method("boolean").EnablePate = function(self, enable)
  local objmap = self.m_ObjMap
  for k, v in pairs(objmap) do
    v:EnablePate(enable)
  end
end
def.method("string", "=>", ECObject).RemoveObj = function(self, id)
  local obj = self.m_ObjMap[id]
  self:OnObjectLeave(obj)
  self.m_ObjMap[id] = nil
  return obj
end
ECManager.Commit()
return ECManager
