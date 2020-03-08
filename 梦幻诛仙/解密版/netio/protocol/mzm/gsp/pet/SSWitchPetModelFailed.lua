local SSWitchPetModelFailed = class("SSWitchPetModelFailed")
SSWitchPetModelFailed.TYPEID = 12590707
SSWitchPetModelFailed.ERROR_SYSTEM = -1
SSWitchPetModelFailed.ERROR_USERID = -2
SSWitchPetModelFailed.ERROR_CFG = -3
SSWitchPetModelFailed.ERROR_PARAM = -4
SSWitchPetModelFailed.ERROR_PET_ACTION_AFTER_FIGHT = -5
SSWitchPetModelFailed.ERROR_NOT_OWN_PET_MODEL = -6
SSWitchPetModelFailed.ERROR_TARGET_PET_MODEL_ALREADY_USED = -7
function SSWitchPetModelFailed:ctor(pet_id, item_cfg_id, retcode)
  self.id = 12590707
  self.pet_id = pet_id or nil
  self.item_cfg_id = item_cfg_id or nil
  self.retcode = retcode or nil
end
function SSWitchPetModelFailed:marshal(os)
  os:marshalInt64(self.pet_id)
  os:marshalInt32(self.item_cfg_id)
  os:marshalInt32(self.retcode)
end
function SSWitchPetModelFailed:unmarshal(os)
  self.pet_id = os:unmarshalInt64()
  self.item_cfg_id = os:unmarshalInt32()
  self.retcode = os:unmarshalInt32()
end
function SSWitchPetModelFailed:sizepolicy(size)
  return size <= 65535
end
return SSWitchPetModelFailed
