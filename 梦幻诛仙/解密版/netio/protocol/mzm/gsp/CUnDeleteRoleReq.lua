local CUnDeleteRoleReq = class("CUnDeleteRoleReq")
CUnDeleteRoleReq.TYPEID = 12590096
function CUnDeleteRoleReq:ctor(roleId)
  self.id = 12590096
  self.roleId = roleId or nil
end
function CUnDeleteRoleReq:marshal(os)
  os:marshalInt64(self.roleId)
end
function CUnDeleteRoleReq:unmarshal(os)
  self.roleId = os:unmarshalInt64()
end
function CUnDeleteRoleReq:sizepolicy(size)
  return size <= 65535
end
return CUnDeleteRoleReq
