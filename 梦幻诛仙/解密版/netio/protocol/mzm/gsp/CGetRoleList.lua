local CGetRoleList = class("CGetRoleList")
CGetRoleList.TYPEID = 12590082
function CGetRoleList:ctor()
  self.id = 12590082
end
function CGetRoleList:marshal(os)
end
function CGetRoleList:unmarshal(os)
end
function CGetRoleList:sizepolicy(size)
  return size <= 65535
end
return CGetRoleList
