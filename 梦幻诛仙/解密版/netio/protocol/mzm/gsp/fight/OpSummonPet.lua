local OctetsStream = require("netio.OctetsStream")
local OpSummonPet = class("OpSummonPet")
function OpSummonPet:ctor(pet_uuid)
  self.pet_uuid = pet_uuid or nil
end
function OpSummonPet:marshal(os)
  os:marshalInt64(self.pet_uuid)
end
function OpSummonPet:unmarshal(os)
  self.pet_uuid = os:unmarshalInt64()
end
return OpSummonPet
