local PetEquipCondition = require("netio.protocol.mzm.gsp.market.PetEquipCondition")
local SAddPetEquipConditionRes = class("SAddPetEquipConditionRes")
SAddPetEquipConditionRes.TYPEID = 12601415
function SAddPetEquipConditionRes:ctor(index, condition)
  self.id = 12601415
  self.index = index or nil
  self.condition = condition or PetEquipCondition.new()
end
function SAddPetEquipConditionRes:marshal(os)
  os:marshalInt32(self.index)
  self.condition:marshal(os)
end
function SAddPetEquipConditionRes:unmarshal(os)
  self.index = os:unmarshalInt32()
  self.condition = PetEquipCondition.new()
  self.condition:unmarshal(os)
end
function SAddPetEquipConditionRes:sizepolicy(size)
  return size <= 65535
end
return SAddPetEquipConditionRes
