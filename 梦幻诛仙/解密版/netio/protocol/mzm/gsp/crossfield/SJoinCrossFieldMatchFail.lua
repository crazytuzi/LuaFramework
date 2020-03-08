local SJoinCrossFieldMatchFail = class("SJoinCrossFieldMatchFail")
SJoinCrossFieldMatchFail.TYPEID = 12619521
function SJoinCrossFieldMatchFail:ctor(res)
  self.id = 12619521
  self.res = res or nil
end
function SJoinCrossFieldMatchFail:marshal(os)
  os:marshalInt32(self.res)
end
function SJoinCrossFieldMatchFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SJoinCrossFieldMatchFail:sizepolicy(size)
  return size <= 65535
end
return SJoinCrossFieldMatchFail
