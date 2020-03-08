local SGetBigBossRemoteRankFail = class("SGetBigBossRemoteRankFail")
SGetBigBossRemoteRankFail.TYPEID = 12598028
function SGetBigBossRemoteRankFail:ctor(res)
  self.id = 12598028
  self.res = res or nil
end
function SGetBigBossRemoteRankFail:marshal(os)
  os:marshalInt32(self.res)
end
function SGetBigBossRemoteRankFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SGetBigBossRemoteRankFail:sizepolicy(size)
  return size <= 65535
end
return SGetBigBossRemoteRankFail
