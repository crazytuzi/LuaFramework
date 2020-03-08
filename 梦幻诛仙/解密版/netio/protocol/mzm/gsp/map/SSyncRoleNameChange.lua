local SSyncRoleNameChange = class("SSyncRoleNameChange")
SSyncRoleNameChange.TYPEID = 12590873
SSyncRoleNameChange.TYPE_ROLE = 0
SSyncRoleNameChange.TYPE_PET = 1
function SSyncRoleNameChange:ctor(roleId, name, nameType)
  self.id = 12590873
  self.roleId = roleId or nil
  self.name = name or nil
  self.nameType = nameType or nil
end
function SSyncRoleNameChange:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalString(self.name)
  os:marshalInt32(self.nameType)
end
function SSyncRoleNameChange:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.name = os:unmarshalString()
  self.nameType = os:unmarshalInt32()
end
function SSyncRoleNameChange:sizepolicy(size)
  return size <= 65535
end
return SSyncRoleNameChange
