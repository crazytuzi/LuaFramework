local CDeletePetModel = class("CDeletePetModel")
CDeletePetModel.TYPEID = 12590710
function CDeletePetModel:ctor(pet_id, item_cfg_id)
  self.id = 12590710
  self.pet_id = pet_id or nil
  self.item_cfg_id = item_cfg_id or nil
end
function CDeletePetModel:marshal(os)
  os:marshalInt64(self.pet_id)
  os:marshalInt32(self.item_cfg_id)
end
function CDeletePetModel:unmarshal(os)
  self.pet_id = os:unmarshalInt64()
  self.item_cfg_id = os:unmarshalInt32()
end
function CDeletePetModel:sizepolicy(size)
  return size <= 65535
end
return CDeletePetModel
