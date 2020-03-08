local SPregnantCutVigorFail = class("SPregnantCutVigorFail")
SPregnantCutVigorFail.TYPEID = 12609336
function SPregnantCutVigorFail:ctor(role_id)
  self.id = 12609336
  self.role_id = role_id or nil
end
function SPregnantCutVigorFail:marshal(os)
  os:marshalInt64(self.role_id)
end
function SPregnantCutVigorFail:unmarshal(os)
  self.role_id = os:unmarshalInt64()
end
function SPregnantCutVigorFail:sizepolicy(size)
  return size <= 65535
end
return SPregnantCutVigorFail
