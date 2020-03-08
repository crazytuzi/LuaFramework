local SDeletePetModelFailed = class("SDeletePetModelFailed")
SDeletePetModelFailed.TYPEID = 12590708
SDeletePetModelFailed.ERROR_SYSTEM = -1
SDeletePetModelFailed.ERROR_USERID = -2
SDeletePetModelFailed.ERROR_CFG = -3
SDeletePetModelFailed.ERROR_PARAM = -4
SDeletePetModelFailed.ERROR_USED_CAN_NOT_DELETE = -5
SDeletePetModelFailed.ERROR_NOT_OWN_PET_MODEL = -6
function SDeletePetModelFailed:ctor(pet_id, item_cfg_id, retcode)
  self.id = 12590708
  self.pet_id = pet_id or nil
  self.item_cfg_id = item_cfg_id or nil
  self.retcode = retcode or nil
end
function SDeletePetModelFailed:marshal(os)
  os:marshalInt64(self.pet_id)
  os:marshalInt32(self.item_cfg_id)
  os:marshalInt32(self.retcode)
end
function SDeletePetModelFailed:unmarshal(os)
  self.pet_id = os:unmarshalInt64()
  self.item_cfg_id = os:unmarshalInt32()
  self.retcode = os:unmarshalInt32()
end
function SDeletePetModelFailed:sizepolicy(size)
  return size <= 65535
end
return SDeletePetModelFailed
