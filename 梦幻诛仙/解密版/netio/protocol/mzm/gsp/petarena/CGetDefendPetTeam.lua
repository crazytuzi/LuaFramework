local CGetDefendPetTeam = class("CGetDefendPetTeam")
CGetDefendPetTeam.TYPEID = 12628243
function CGetDefendPetTeam:ctor(target_roleid, rank, serial)
  self.id = 12628243
  self.target_roleid = target_roleid or nil
  self.rank = rank or nil
  self.serial = serial or nil
end
function CGetDefendPetTeam:marshal(os)
  os:marshalInt64(self.target_roleid)
  os:marshalInt32(self.rank)
  os:marshalInt32(self.serial)
end
function CGetDefendPetTeam:unmarshal(os)
  self.target_roleid = os:unmarshalInt64()
  self.rank = os:unmarshalInt32()
  self.serial = os:unmarshalInt32()
end
function CGetDefendPetTeam:sizepolicy(size)
  return size <= 65535
end
return CGetDefendPetTeam
