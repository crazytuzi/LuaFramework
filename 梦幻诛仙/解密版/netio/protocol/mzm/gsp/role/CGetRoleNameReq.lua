local CGetRoleNameReq = class("CGetRoleNameReq")
CGetRoleNameReq.TYPEID = 12586038
function CGetRoleNameReq:ctor(checkedRoleId)
  self.id = 12586038
  self.checkedRoleId = checkedRoleId or nil
end
function CGetRoleNameReq:marshal(os)
  os:marshalInt64(self.checkedRoleId)
end
function CGetRoleNameReq:unmarshal(os)
  self.checkedRoleId = os:unmarshalInt64()
end
function CGetRoleNameReq:sizepolicy(size)
  return size <= 65535
end
return CGetRoleNameReq
