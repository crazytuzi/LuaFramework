local PetFightInfo = require("netio.protocol.mzm.gsp.pet.PetFightInfo")
local SSyncPetFightInformation = class("SSyncPetFightInformation")
SSyncPetFightInformation.TYPEID = 12590689
function SSyncPetFightInformation:ctor(info)
  self.id = 12590689
  self.info = info or PetFightInfo.new()
end
function SSyncPetFightInformation:marshal(os)
  self.info:marshal(os)
end
function SSyncPetFightInformation:unmarshal(os)
  self.info = PetFightInfo.new()
  self.info:unmarshal(os)
end
function SSyncPetFightInformation:sizepolicy(size)
  return size <= 65535
end
return SSyncPetFightInformation
