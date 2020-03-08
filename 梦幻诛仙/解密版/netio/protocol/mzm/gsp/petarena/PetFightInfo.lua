local OctetsStream = require("netio.OctetsStream")
local PetFightInfo = class("PetFightInfo")
function PetFightInfo:ctor(petid, position, pet_cfgid, monster_cfgid, damage, name)
  self.petid = petid or nil
  self.position = position or nil
  self.pet_cfgid = pet_cfgid or nil
  self.monster_cfgid = monster_cfgid or nil
  self.damage = damage or nil
  self.name = name or nil
end
function PetFightInfo:marshal(os)
  os:marshalInt64(self.petid)
  os:marshalInt32(self.position)
  os:marshalInt32(self.pet_cfgid)
  os:marshalInt32(self.monster_cfgid)
  os:marshalInt32(self.damage)
  os:marshalOctets(self.name)
end
function PetFightInfo:unmarshal(os)
  self.petid = os:unmarshalInt64()
  self.position = os:unmarshalInt32()
  self.pet_cfgid = os:unmarshalInt32()
  self.monster_cfgid = os:unmarshalInt32()
  self.damage = os:unmarshalInt32()
  self.name = os:unmarshalOctets()
end
return PetFightInfo
