local SGetCrossFieldRankFail = class("SGetCrossFieldRankFail")
SGetCrossFieldRankFail.TYPEID = 12619533
function SGetCrossFieldRankFail:ctor(res)
  self.id = 12619533
  self.res = res or nil
end
function SGetCrossFieldRankFail:marshal(os)
  os:marshalInt32(self.res)
end
function SGetCrossFieldRankFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SGetCrossFieldRankFail:sizepolicy(size)
  return size <= 65535
end
return SGetCrossFieldRankFail
