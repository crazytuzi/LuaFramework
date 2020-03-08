local SPraisePersonalFailed = class("SPraisePersonalFailed")
SPraisePersonalFailed.TYPEID = 12603652
function SPraisePersonalFailed:ctor(roleId, retcode)
  self.id = 12603652
  self.roleId = roleId or nil
  self.retcode = retcode or nil
end
function SPraisePersonalFailed:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalInt32(self.retcode)
end
function SPraisePersonalFailed:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.retcode = os:unmarshalInt32()
end
function SPraisePersonalFailed:sizepolicy(size)
  return size <= 65535
end
return SPraisePersonalFailed
