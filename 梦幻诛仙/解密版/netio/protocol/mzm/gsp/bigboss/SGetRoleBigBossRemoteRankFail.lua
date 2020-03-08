local SGetRoleBigBossRemoteRankFail = class("SGetRoleBigBossRemoteRankFail")
SGetRoleBigBossRemoteRankFail.TYPEID = 12598032
function SGetRoleBigBossRemoteRankFail:ctor(res)
  self.id = 12598032
  self.res = res or nil
end
function SGetRoleBigBossRemoteRankFail:marshal(os)
  os:marshalInt32(self.res)
end
function SGetRoleBigBossRemoteRankFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SGetRoleBigBossRemoteRankFail:sizepolicy(size)
  return size <= 65535
end
return SGetRoleBigBossRemoteRankFail
