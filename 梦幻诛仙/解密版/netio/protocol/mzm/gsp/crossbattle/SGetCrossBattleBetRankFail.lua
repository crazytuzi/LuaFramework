local SGetCrossBattleBetRankFail = class("SGetCrossBattleBetRankFail")
SGetCrossBattleBetRankFail.TYPEID = 12617096
function SGetCrossBattleBetRankFail:ctor(res)
  self.id = 12617096
  self.res = res or nil
end
function SGetCrossBattleBetRankFail:marshal(os)
  os:marshalInt32(self.res)
end
function SGetCrossBattleBetRankFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SGetCrossBattleBetRankFail:sizepolicy(size)
  return size <= 65535
end
return SGetCrossBattleBetRankFail
