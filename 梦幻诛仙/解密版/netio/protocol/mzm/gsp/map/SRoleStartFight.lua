local SRoleStartFight = class("SRoleStartFight")
SRoleStartFight.TYPEID = 12590852
function SRoleStartFight:ctor(roleId)
  self.id = 12590852
  self.roleId = roleId or nil
end
function SRoleStartFight:marshal(os)
  os:marshalInt64(self.roleId)
end
function SRoleStartFight:unmarshal(os)
  self.roleId = os:unmarshalInt64()
end
function SRoleStartFight:sizepolicy(size)
  return size <= 65535
end
return SRoleStartFight
