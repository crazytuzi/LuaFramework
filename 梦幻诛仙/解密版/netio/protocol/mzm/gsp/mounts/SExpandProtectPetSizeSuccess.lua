local SExpandProtectPetSizeSuccess = class("SExpandProtectPetSizeSuccess")
SExpandProtectPetSizeSuccess.TYPEID = 12606250
function SExpandProtectPetSizeSuccess:ctor(mounts_id, protect_pet_expand_size)
  self.id = 12606250
  self.mounts_id = mounts_id or nil
  self.protect_pet_expand_size = protect_pet_expand_size or nil
end
function SExpandProtectPetSizeSuccess:marshal(os)
  os:marshalInt64(self.mounts_id)
  os:marshalInt32(self.protect_pet_expand_size)
end
function SExpandProtectPetSizeSuccess:unmarshal(os)
  self.mounts_id = os:unmarshalInt64()
  self.protect_pet_expand_size = os:unmarshalInt32()
end
function SExpandProtectPetSizeSuccess:sizepolicy(size)
  return size <= 65535
end
return SExpandProtectPetSizeSuccess
