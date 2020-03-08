local PetCondition = require("netio.protocol.mzm.gsp.market.PetCondition")
local SAddPetConditionRes = class("SAddPetConditionRes")
SAddPetConditionRes.TYPEID = 12601409
function SAddPetConditionRes:ctor(index, condition)
  self.id = 12601409
  self.index = index or nil
  self.condition = condition or PetCondition.new()
end
function SAddPetConditionRes:marshal(os)
  os:marshalInt32(self.index)
  self.condition:marshal(os)
end
function SAddPetConditionRes:unmarshal(os)
  self.index = os:unmarshalInt32()
  self.condition = PetCondition.new()
  self.condition:unmarshal(os)
end
function SAddPetConditionRes:sizepolicy(size)
  return size <= 65535
end
return SAddPetConditionRes
