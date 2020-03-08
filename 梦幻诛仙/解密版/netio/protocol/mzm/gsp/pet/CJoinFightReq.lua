local CJoinFightReq = class("CJoinFightReq")
CJoinFightReq.TYPEID = 12590600
function CJoinFightReq:ctor(petId)
  self.id = 12590600
  self.petId = petId or nil
end
function CJoinFightReq:marshal(os)
  os:marshalInt64(self.petId)
end
function CJoinFightReq:unmarshal(os)
  self.petId = os:unmarshalInt64()
end
function CJoinFightReq:sizepolicy(size)
  return size <= 65535
end
return CJoinFightReq
