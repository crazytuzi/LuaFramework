local SUnDeleteRoleRes = class("SUnDeleteRoleRes")
SUnDeleteRoleRes.TYPEID = 12590093
function SUnDeleteRoleRes:ctor(roleId)
  self.id = 12590093
  self.roleId = roleId or nil
end
function SUnDeleteRoleRes:marshal(os)
  os:marshalInt64(self.roleId)
end
function SUnDeleteRoleRes:unmarshal(os)
  self.roleId = os:unmarshalInt64()
end
function SUnDeleteRoleRes:sizepolicy(size)
  return size <= 65535
end
return SUnDeleteRoleRes
