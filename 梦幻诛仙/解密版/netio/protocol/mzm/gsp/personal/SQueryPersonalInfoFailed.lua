local SQueryPersonalInfoFailed = class("SQueryPersonalInfoFailed")
SQueryPersonalInfoFailed.TYPEID = 12603657
function SQueryPersonalInfoFailed:ctor(roleId, retcode)
  self.id = 12603657
  self.roleId = roleId or nil
  self.retcode = retcode or nil
end
function SQueryPersonalInfoFailed:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalInt32(self.retcode)
end
function SQueryPersonalInfoFailed:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.retcode = os:unmarshalInt32()
end
function SQueryPersonalInfoFailed:sizepolicy(size)
  return size <= 65535
end
return SQueryPersonalInfoFailed
