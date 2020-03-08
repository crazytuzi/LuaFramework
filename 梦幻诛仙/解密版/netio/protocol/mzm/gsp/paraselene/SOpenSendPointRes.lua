local SOpenSendPointRes = class("SOpenSendPointRes")
SOpenSendPointRes.TYPEID = 12598275
function SOpenSendPointRes:ctor(npc, npcservice)
  self.id = 12598275
  self.npc = npc or nil
  self.npcservice = npcservice or nil
end
function SOpenSendPointRes:marshal(os)
  os:marshalInt32(self.npc)
  os:marshalInt32(self.npcservice)
end
function SOpenSendPointRes:unmarshal(os)
  self.npc = os:unmarshalInt32()
  self.npcservice = os:unmarshalInt32()
end
function SOpenSendPointRes:sizepolicy(size)
  return size <= 65535
end
return SOpenSendPointRes
