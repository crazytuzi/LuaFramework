local SSyncUnForbiddenTalk = class("SSyncUnForbiddenTalk")
SSyncUnForbiddenTalk.TYPEID = 12589845
function SSyncUnForbiddenTalk:ctor(managerId, roleId)
  self.id = 12589845
  self.managerId = managerId or nil
  self.roleId = roleId or nil
end
function SSyncUnForbiddenTalk:marshal(os)
  os:marshalInt64(self.managerId)
  os:marshalInt64(self.roleId)
end
function SSyncUnForbiddenTalk:unmarshal(os)
  self.managerId = os:unmarshalInt64()
  self.roleId = os:unmarshalInt64()
end
function SSyncUnForbiddenTalk:sizepolicy(size)
  return size <= 65535
end
return SSyncUnForbiddenTalk
