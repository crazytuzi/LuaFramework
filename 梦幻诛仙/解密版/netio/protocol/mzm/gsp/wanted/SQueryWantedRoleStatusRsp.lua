local SQueryWantedRoleStatusRsp = class("SQueryWantedRoleStatusRsp")
SQueryWantedRoleStatusRsp.TYPEID = 12620302
function SQueryWantedRoleStatusRsp:ctor(roleId, power, mapId, teamMemberCount)
  self.id = 12620302
  self.roleId = roleId or nil
  self.power = power or nil
  self.mapId = mapId or nil
  self.teamMemberCount = teamMemberCount or nil
end
function SQueryWantedRoleStatusRsp:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalInt32(self.power)
  os:marshalInt32(self.mapId)
  os:marshalInt32(self.teamMemberCount)
end
function SQueryWantedRoleStatusRsp:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.power = os:unmarshalInt32()
  self.mapId = os:unmarshalInt32()
  self.teamMemberCount = os:unmarshalInt32()
end
function SQueryWantedRoleStatusRsp:sizepolicy(size)
  return size <= 65535
end
return SQueryWantedRoleStatusRsp
