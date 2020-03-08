local CDisAgreeApply = class("CDisAgreeApply")
CDisAgreeApply.TYPEID = 12587027
function CDisAgreeApply:ctor(strangerId)
  self.id = 12587027
  self.strangerId = strangerId or nil
end
function CDisAgreeApply:marshal(os)
  os:marshalInt64(self.strangerId)
end
function CDisAgreeApply:unmarshal(os)
  self.strangerId = os:unmarshalInt64()
end
function CDisAgreeApply:sizepolicy(size)
  return size <= 65535
end
return CDisAgreeApply
