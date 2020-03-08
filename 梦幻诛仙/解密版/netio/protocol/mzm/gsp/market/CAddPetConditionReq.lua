local PetCondition = require("netio.protocol.mzm.gsp.market.PetCondition")
local CAddPetConditionReq = class("CAddPetConditionReq")
CAddPetConditionReq.TYPEID = 12601406
function CAddPetConditionReq:ctor(condition)
  self.id = 12601406
  self.condition = condition or PetCondition.new()
end
function CAddPetConditionReq:marshal(os)
  self.condition:marshal(os)
end
function CAddPetConditionReq:unmarshal(os)
  self.condition = PetCondition.new()
  self.condition:unmarshal(os)
end
function CAddPetConditionReq:sizepolicy(size)
  return size <= 65535
end
return CAddPetConditionReq
