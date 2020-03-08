local CStartLayerTask = class("CStartLayerTask")
CStartLayerTask.TYPEID = 12598277
function CStartLayerTask:ctor(npc, npcservice)
  self.id = 12598277
  self.npc = npc or nil
  self.npcservice = npcservice or nil
end
function CStartLayerTask:marshal(os)
  os:marshalInt32(self.npc)
  os:marshalInt32(self.npcservice)
end
function CStartLayerTask:unmarshal(os)
  self.npc = os:unmarshalInt32()
  self.npcservice = os:unmarshalInt32()
end
function CStartLayerTask:sizepolicy(size)
  return size <= 65535
end
return CStartLayerTask
