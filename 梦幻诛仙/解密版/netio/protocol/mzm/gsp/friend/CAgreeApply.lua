local CAgreeApply = class("CAgreeApply")
CAgreeApply.TYPEID = 12587014
function CAgreeApply:ctor(strangerId)
  self.id = 12587014
  self.strangerId = strangerId or nil
end
function CAgreeApply:marshal(os)
  os:marshalInt64(self.strangerId)
end
function CAgreeApply:unmarshal(os)
  self.strangerId = os:unmarshalInt64()
end
function CAgreeApply:sizepolicy(size)
  return size <= 65535
end
return CAgreeApply
