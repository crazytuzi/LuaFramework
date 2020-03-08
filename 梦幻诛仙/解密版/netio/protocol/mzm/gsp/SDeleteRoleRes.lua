local SDeleteRoleRes = class("SDeleteRoleRes")
SDeleteRoleRes.TYPEID = 12590094
function SDeleteRoleRes:ctor(roleId, endTime)
  self.id = 12590094
  self.roleId = roleId or nil
  self.endTime = endTime or nil
end
function SDeleteRoleRes:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalInt32(self.endTime)
end
function SDeleteRoleRes:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.endTime = os:unmarshalInt32()
end
function SDeleteRoleRes:sizepolicy(size)
  return size <= 65535
end
return SDeleteRoleRes
