local PetInfo = require("netio.protocol.mzm.gsp.pet.PetInfo")
local SFanShengRes = class("SFanShengRes")
SFanShengRes.TYPEID = 12590598
function SFanShengRes:ctor(oldPetId, newPetInfo)
  self.id = 12590598
  self.oldPetId = oldPetId or nil
  self.newPetInfo = newPetInfo or PetInfo.new()
end
function SFanShengRes:marshal(os)
  os:marshalInt64(self.oldPetId)
  self.newPetInfo:marshal(os)
end
function SFanShengRes:unmarshal(os)
  self.oldPetId = os:unmarshalInt64()
  self.newPetInfo = PetInfo.new()
  self.newPetInfo:unmarshal(os)
end
function SFanShengRes:sizepolicy(size)
  return size <= 65535
end
return SFanShengRes
