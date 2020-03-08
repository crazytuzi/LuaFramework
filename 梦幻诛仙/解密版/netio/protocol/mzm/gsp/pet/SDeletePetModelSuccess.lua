local SDeletePetModelSuccess = class("SDeletePetModelSuccess")
SDeletePetModelSuccess.TYPEID = 12590709
function SDeletePetModelSuccess:ctor(pet_id, item_cfg_id)
  self.id = 12590709
  self.pet_id = pet_id or nil
  self.item_cfg_id = item_cfg_id or nil
end
function SDeletePetModelSuccess:marshal(os)
  os:marshalInt64(self.pet_id)
  os:marshalInt32(self.item_cfg_id)
end
function SDeletePetModelSuccess:unmarshal(os)
  self.pet_id = os:unmarshalInt64()
  self.item_cfg_id = os:unmarshalInt32()
end
function SDeletePetModelSuccess:sizepolicy(size)
  return size <= 65535
end
return SDeletePetModelSuccess
