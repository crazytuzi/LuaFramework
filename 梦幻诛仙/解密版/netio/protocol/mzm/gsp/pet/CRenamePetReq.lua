local CRenamePetReq = class("CRenamePetReq")
CRenamePetReq.TYPEID = 12590601
function CRenamePetReq:ctor(petId, petName)
  self.id = 12590601
  self.petId = petId or nil
  self.petName = petName or nil
end
function CRenamePetReq:marshal(os)
  os:marshalInt64(self.petId)
  os:marshalString(self.petName)
end
function CRenamePetReq:unmarshal(os)
  self.petId = os:unmarshalInt64()
  self.petName = os:unmarshalString()
end
function CRenamePetReq:sizepolicy(size)
  return size <= 65535
end
return CRenamePetReq
