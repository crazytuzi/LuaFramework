local CQueryRoleModelInfoReq = class("CQueryRoleModelInfoReq")
CQueryRoleModelInfoReq.TYPEID = 12600847
function CQueryRoleModelInfoReq:ctor(roleid)
  self.id = 12600847
  self.roleid = roleid or nil
end
function CQueryRoleModelInfoReq:marshal(os)
  os:marshalInt64(self.roleid)
end
function CQueryRoleModelInfoReq:unmarshal(os)
  self.roleid = os:unmarshalInt64()
end
function CQueryRoleModelInfoReq:sizepolicy(size)
  return size <= 65535
end
return CQueryRoleModelInfoReq
