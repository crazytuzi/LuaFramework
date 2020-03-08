local CEnterArenaMapReq = class("CEnterArenaMapReq")
CEnterArenaMapReq.TYPEID = 12596740
function CEnterArenaMapReq:ctor(npc)
  self.id = 12596740
  self.npc = npc or nil
end
function CEnterArenaMapReq:marshal(os)
  os:marshalInt32(self.npc)
end
function CEnterArenaMapReq:unmarshal(os)
  self.npc = os:unmarshalInt32()
end
function CEnterArenaMapReq:sizepolicy(size)
  return size <= 65535
end
return CEnterArenaMapReq
