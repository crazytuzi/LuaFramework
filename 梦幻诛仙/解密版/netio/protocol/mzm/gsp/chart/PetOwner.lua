local OctetsStream = require("netio.OctetsStream")
local PetOwner = class("PetOwner")
function PetOwner:ctor(roleId, petId)
  self.roleId = roleId or nil
  self.petId = petId or nil
end
function PetOwner:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalInt64(self.petId)
end
function PetOwner:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.petId = os:unmarshalInt64()
end
return PetOwner
