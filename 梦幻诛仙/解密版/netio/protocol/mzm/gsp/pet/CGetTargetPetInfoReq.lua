local CGetTargetPetInfoReq = class("CGetTargetPetInfoReq")
CGetTargetPetInfoReq.TYPEID = 12590608
function CGetTargetPetInfoReq:ctor(roleId, petId)
  self.id = 12590608
  self.roleId = roleId or nil
  self.petId = petId or nil
end
function CGetTargetPetInfoReq:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalInt64(self.petId)
end
function CGetTargetPetInfoReq:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.petId = os:unmarshalInt64()
end
function CGetTargetPetInfoReq:sizepolicy(size)
  return size <= 65535
end
return CGetTargetPetInfoReq
