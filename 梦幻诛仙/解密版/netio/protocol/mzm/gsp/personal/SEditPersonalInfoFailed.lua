local SEditPersonalInfoFailed = class("SEditPersonalInfoFailed")
SEditPersonalInfoFailed.TYPEID = 12603653
function SEditPersonalInfoFailed:ctor(roleId, retcode)
  self.id = 12603653
  self.roleId = roleId or nil
  self.retcode = retcode or nil
end
function SEditPersonalInfoFailed:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalInt32(self.retcode)
end
function SEditPersonalInfoFailed:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.retcode = os:unmarshalInt32()
end
function SEditPersonalInfoFailed:sizepolicy(size)
  return size <= 65535
end
return SEditPersonalInfoFailed
