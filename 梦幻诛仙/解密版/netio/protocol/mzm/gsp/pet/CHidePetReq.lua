local CHidePetReq = class("CHidePetReq")
CHidePetReq.TYPEID = 12590622
function CHidePetReq:ctor(petId)
  self.id = 12590622
  self.petId = petId or nil
end
function CHidePetReq:marshal(os)
  os:marshalInt64(self.petId)
end
function CHidePetReq:unmarshal(os)
  self.petId = os:unmarshalInt64()
end
function CHidePetReq:sizepolicy(size)
  return size <= 65535
end
return CHidePetReq
