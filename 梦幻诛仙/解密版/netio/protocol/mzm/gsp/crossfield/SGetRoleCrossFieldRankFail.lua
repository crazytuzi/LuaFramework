local SGetRoleCrossFieldRankFail = class("SGetRoleCrossFieldRankFail")
SGetRoleCrossFieldRankFail.TYPEID = 12619535
function SGetRoleCrossFieldRankFail:ctor(res)
  self.id = 12619535
  self.res = res or nil
end
function SGetRoleCrossFieldRankFail:marshal(os)
  os:marshalInt32(self.res)
end
function SGetRoleCrossFieldRankFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SGetRoleCrossFieldRankFail:sizepolicy(size)
  return size <= 65535
end
return SGetRoleCrossFieldRankFail
