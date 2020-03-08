local SSynMemberMFVChange = class("SSynMemberMFVChange")
SSynMemberMFVChange.TYPEID = 12617521
function SSynMemberMFVChange:ctor(roleId, multiFightValue)
  self.id = 12617521
  self.roleId = roleId or nil
  self.multiFightValue = multiFightValue or nil
end
function SSynMemberMFVChange:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalInt32(self.multiFightValue)
end
function SSynMemberMFVChange:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.multiFightValue = os:unmarshalInt32()
end
function SSynMemberMFVChange:sizepolicy(size)
  return size <= 65535
end
return SSynMemberMFVChange
