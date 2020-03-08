local CReleasePetReq = class("CReleasePetReq")
CReleasePetReq.TYPEID = 12590606
function CReleasePetReq:ctor(petId)
  self.id = 12590606
  self.petId = petId or nil
end
function CReleasePetReq:marshal(os)
  os:marshalInt64(self.petId)
end
function CReleasePetReq:unmarshal(os)
  self.petId = os:unmarshalInt64()
end
function CReleasePetReq:sizepolicy(size)
  return size <= 65535
end
return CReleasePetReq
