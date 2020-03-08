local CDeleteRoleReq = class("CDeleteRoleReq")
CDeleteRoleReq.TYPEID = 12590095
function CDeleteRoleReq:ctor(roleId)
  self.id = 12590095
  self.roleId = roleId or nil
end
function CDeleteRoleReq:marshal(os)
  os:marshalInt64(self.roleId)
end
function CDeleteRoleReq:unmarshal(os)
  self.roleId = os:unmarshalInt64()
end
function CDeleteRoleReq:sizepolicy(size)
  return size <= 65535
end
return CDeleteRoleReq
