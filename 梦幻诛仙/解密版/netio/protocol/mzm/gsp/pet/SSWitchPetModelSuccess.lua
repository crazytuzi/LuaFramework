local SSWitchPetModelSuccess = class("SSWitchPetModelSuccess")
SSWitchPetModelSuccess.TYPEID = 12590705
function SSWitchPetModelSuccess:ctor(pet_id, item_cfg_id)
  self.id = 12590705
  self.pet_id = pet_id or nil
  self.item_cfg_id = item_cfg_id or nil
end
function SSWitchPetModelSuccess:marshal(os)
  os:marshalInt64(self.pet_id)
  os:marshalInt32(self.item_cfg_id)
end
function SSWitchPetModelSuccess:unmarshal(os)
  self.pet_id = os:unmarshalInt64()
  self.item_cfg_id = os:unmarshalInt32()
end
function SSWitchPetModelSuccess:sizepolicy(size)
  return size <= 65535
end
return SSWitchPetModelSuccess
