local SAgreeApplyRes = class("SAgreeApplyRes")
SAgreeApplyRes.TYPEID = 12587024
function SAgreeApplyRes:ctor(strangerId)
  self.id = 12587024
  self.strangerId = strangerId or nil
end
function SAgreeApplyRes:marshal(os)
  os:marshalInt64(self.strangerId)
end
function SAgreeApplyRes:unmarshal(os)
  self.strangerId = os:unmarshalInt64()
end
function SAgreeApplyRes:sizepolicy(size)
  return size <= 65535
end
return SAgreeApplyRes
