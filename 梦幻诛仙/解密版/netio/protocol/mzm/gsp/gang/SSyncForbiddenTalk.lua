local SSyncForbiddenTalk = class("SSyncForbiddenTalk")
SSyncForbiddenTalk.TYPEID = 12589862
function SSyncForbiddenTalk:ctor(managerId, roleId)
  self.id = 12589862
  self.managerId = managerId or nil
  self.roleId = roleId or nil
end
function SSyncForbiddenTalk:marshal(os)
  os:marshalInt64(self.managerId)
  os:marshalInt64(self.roleId)
end
function SSyncForbiddenTalk:unmarshal(os)
  self.managerId = os:unmarshalInt64()
  self.roleId = os:unmarshalInt64()
end
function SSyncForbiddenTalk:sizepolicy(size)
  return size <= 65535
end
return SSyncForbiddenTalk
