local SRoleEndFight = class("SRoleEndFight")
SRoleEndFight.TYPEID = 12590887
function SRoleEndFight:ctor(roleId)
  self.id = 12590887
  self.roleId = roleId or nil
end
function SRoleEndFight:marshal(os)
  os:marshalInt64(self.roleId)
end
function SRoleEndFight:unmarshal(os)
  self.roleId = os:unmarshalInt64()
end
function SRoleEndFight:sizepolicy(size)
  return size <= 65535
end
return SRoleEndFight
