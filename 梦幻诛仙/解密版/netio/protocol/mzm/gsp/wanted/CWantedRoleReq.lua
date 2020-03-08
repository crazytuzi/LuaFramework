local CWantedRoleReq = class("CWantedRoleReq")
CWantedRoleReq.TYPEID = 12620296
function CWantedRoleReq:ctor(roleId)
  self.id = 12620296
  self.roleId = roleId or nil
end
function CWantedRoleReq:marshal(os)
  os:marshalInt64(self.roleId)
end
function CWantedRoleReq:unmarshal(os)
  self.roleId = os:unmarshalInt64()
end
function CWantedRoleReq:sizepolicy(size)
  return size <= 65535
end
return CWantedRoleReq
