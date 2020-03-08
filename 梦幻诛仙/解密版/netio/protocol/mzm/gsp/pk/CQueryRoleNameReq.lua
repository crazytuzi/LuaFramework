local CQueryRoleNameReq = class("CQueryRoleNameReq")
CQueryRoleNameReq.TYPEID = 12619802
function CQueryRoleNameReq:ctor(role_id)
  self.id = 12619802
  self.role_id = role_id or nil
end
function CQueryRoleNameReq:marshal(os)
  os:marshalInt64(self.role_id)
end
function CQueryRoleNameReq:unmarshal(os)
  self.role_id = os:unmarshalInt64()
end
function CQueryRoleNameReq:sizepolicy(size)
  return size <= 65535
end
return CQueryRoleNameReq
