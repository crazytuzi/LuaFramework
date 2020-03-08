local SGetRoleCrossBattleBetRankFail = class("SGetRoleCrossBattleBetRankFail")
SGetRoleCrossBattleBetRankFail.TYPEID = 12617098
function SGetRoleCrossBattleBetRankFail:ctor(res)
  self.id = 12617098
  self.res = res or nil
end
function SGetRoleCrossBattleBetRankFail:marshal(os)
  os:marshalInt32(self.res)
end
function SGetRoleCrossBattleBetRankFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SGetRoleCrossBattleBetRankFail:sizepolicy(size)
  return size <= 65535
end
return SGetRoleCrossBattleBetRankFail
