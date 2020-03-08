local CGetRoleInfoReq = class("CGetRoleInfoReq")
CGetRoleInfoReq.TYPEID = 12586013
function CGetRoleInfoReq:ctor(roleId)
  self.id = 12586013
  self.roleId = roleId or nil
end
function CGetRoleInfoReq:marshal(os)
  os:marshalInt64(self.roleId)
end
function CGetRoleInfoReq:unmarshal(os)
  self.roleId = os:unmarshalInt64()
end
function CGetRoleInfoReq:sizepolicy(size)
  return size <= 65535
end
return CGetRoleInfoReq
