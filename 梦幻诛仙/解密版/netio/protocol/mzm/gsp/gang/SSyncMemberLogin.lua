local SSyncMemberLogin = class("SSyncMemberLogin")
SSyncMemberLogin.TYPEID = 12589878
function SSyncMemberLogin:ctor(roleId)
  self.id = 12589878
  self.roleId = roleId or nil
end
function SSyncMemberLogin:marshal(os)
  os:marshalInt64(self.roleId)
end
function SSyncMemberLogin:unmarshal(os)
  self.roleId = os:unmarshalInt64()
end
function SSyncMemberLogin:sizepolicy(size)
  return size <= 65535
end
return SSyncMemberLogin
