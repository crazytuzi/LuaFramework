local CEnterMenpaiMapReq = class("CEnterMenpaiMapReq")
CEnterMenpaiMapReq.TYPEID = 12596227
function CEnterMenpaiMapReq:ctor(npc)
  self.id = 12596227
  self.npc = npc or nil
end
function CEnterMenpaiMapReq:marshal(os)
  os:marshalInt32(self.npc)
end
function CEnterMenpaiMapReq:unmarshal(os)
  self.npc = os:unmarshalInt32()
end
function CEnterMenpaiMapReq:sizepolicy(size)
  return size <= 65535
end
return CEnterMenpaiMapReq
