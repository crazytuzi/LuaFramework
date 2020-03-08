local SSyncKickOutMember = class("SSyncKickOutMember")
SSyncKickOutMember.TYPEID = 12589825
function SSyncKickOutMember:ctor(roleId, managerId)
  self.id = 12589825
  self.roleId = roleId or nil
  self.managerId = managerId or nil
end
function SSyncKickOutMember:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalInt64(self.managerId)
end
function SSyncKickOutMember:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.managerId = os:unmarshalInt64()
end
function SSyncKickOutMember:sizepolicy(size)
  return size <= 65535
end
return SSyncKickOutMember
