local CQueryWantedRoleStatusReq = class("CQueryWantedRoleStatusReq")
CQueryWantedRoleStatusReq.TYPEID = 12620301
function CQueryWantedRoleStatusReq:ctor(roleId)
  self.id = 12620301
  self.roleId = roleId or nil
end
function CQueryWantedRoleStatusReq:marshal(os)
  os:marshalInt64(self.roleId)
end
function CQueryWantedRoleStatusReq:unmarshal(os)
  self.roleId = os:unmarshalInt64()
end
function CQueryWantedRoleStatusReq:sizepolicy(size)
  return size <= 65535
end
return CQueryWantedRoleStatusReq
