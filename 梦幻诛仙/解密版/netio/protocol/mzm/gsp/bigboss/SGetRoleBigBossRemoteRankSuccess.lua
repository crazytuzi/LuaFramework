local SGetRoleBigBossRemoteRankSuccess = class("SGetRoleBigBossRemoteRankSuccess")
SGetRoleBigBossRemoteRankSuccess.TYPEID = 12598031
function SGetRoleBigBossRemoteRankSuccess:ctor(occupation, damage_point, rank)
  self.id = 12598031
  self.occupation = occupation or nil
  self.damage_point = damage_point or nil
  self.rank = rank or nil
end
function SGetRoleBigBossRemoteRankSuccess:marshal(os)
  os:marshalInt32(self.occupation)
  os:marshalInt32(self.damage_point)
  os:marshalInt32(self.rank)
end
function SGetRoleBigBossRemoteRankSuccess:unmarshal(os)
  self.occupation = os:unmarshalInt32()
  self.damage_point = os:unmarshalInt32()
  self.rank = os:unmarshalInt32()
end
function SGetRoleBigBossRemoteRankSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetRoleBigBossRemoteRankSuccess
