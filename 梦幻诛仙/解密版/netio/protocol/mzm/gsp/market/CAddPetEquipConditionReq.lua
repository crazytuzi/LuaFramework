local PetEquipCondition = require("netio.protocol.mzm.gsp.market.PetEquipCondition")
local CAddPetEquipConditionReq = class("CAddPetEquipConditionReq")
CAddPetEquipConditionReq.TYPEID = 12601417
function CAddPetEquipConditionReq:ctor(condition)
  self.id = 12601417
  self.condition = condition or PetEquipCondition.new()
end
function CAddPetEquipConditionReq:marshal(os)
  self.condition:marshal(os)
end
function CAddPetEquipConditionReq:unmarshal(os)
  self.condition = PetEquipCondition.new()
  self.condition:unmarshal(os)
end
function CAddPetEquipConditionReq:sizepolicy(size)
  return size <= 65535
end
return CAddPetEquipConditionReq
