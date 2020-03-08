local CSWitchPetModel = class("CSWitchPetModel")
CSWitchPetModel.TYPEID = 12590706
function CSWitchPetModel:ctor(pet_id, item_cfg_id)
  self.id = 12590706
  self.pet_id = pet_id or nil
  self.item_cfg_id = item_cfg_id or nil
end
function CSWitchPetModel:marshal(os)
  os:marshalInt64(self.pet_id)
  os:marshalInt32(self.item_cfg_id)
end
function CSWitchPetModel:unmarshal(os)
  self.pet_id = os:unmarshalInt64()
  self.item_cfg_id = os:unmarshalInt32()
end
function CSWitchPetModel:sizepolicy(size)
  return size <= 65535
end
return CSWitchPetModel
