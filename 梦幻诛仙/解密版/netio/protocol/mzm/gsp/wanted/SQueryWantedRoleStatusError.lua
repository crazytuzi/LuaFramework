local SQueryWantedRoleStatusError = class("SQueryWantedRoleStatusError")
SQueryWantedRoleStatusError.TYPEID = 12620303
SQueryWantedRoleStatusError.ROLE_OFFLINE = 1
SQueryWantedRoleStatusError.ROLE_CAN_NOT_BE_WANTED = 2
function SQueryWantedRoleStatusError:ctor(errorCode, roleId)
  self.id = 12620303
  self.errorCode = errorCode or nil
  self.roleId = roleId or nil
end
function SQueryWantedRoleStatusError:marshal(os)
  os:marshalInt32(self.errorCode)
  os:marshalInt64(self.roleId)
end
function SQueryWantedRoleStatusError:unmarshal(os)
  self.errorCode = os:unmarshalInt32()
  self.roleId = os:unmarshalInt64()
end
function SQueryWantedRoleStatusError:sizepolicy(size)
  return size <= 65535
end
return SQueryWantedRoleStatusError
