local SLogoutBro = class("SLogoutBro")
SLogoutBro.TYPEID = 12621579
function SLogoutBro:ctor(roleId)
  self.id = 12621579
  self.roleId = roleId or nil
end
function SLogoutBro:marshal(os)
  os:marshalInt64(self.roleId)
end
function SLogoutBro:unmarshal(os)
  self.roleId = os:unmarshalInt64()
end
function SLogoutBro:sizepolicy(size)
  return size <= 65535
end
return SLogoutBro
