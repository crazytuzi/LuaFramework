local CGetRoleModelReq = class("CGetRoleModelReq")
CGetRoleModelReq.TYPEID = 12589835
function CGetRoleModelReq:ctor(roleId)
  self.id = 12589835
  self.roleId = roleId or nil
end
function CGetRoleModelReq:marshal(os)
  os:marshalInt64(self.roleId)
end
function CGetRoleModelReq:unmarshal(os)
  self.roleId = os:unmarshalInt64()
end
function CGetRoleModelReq:sizepolicy(size)
  return size <= 65535
end
return CGetRoleModelReq
