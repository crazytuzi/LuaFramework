local CGetRoleModelInfo = class("CGetRoleModelInfo")
CGetRoleModelInfo.TYPEID = 12586027
function CGetRoleModelInfo:ctor(targetRoleId)
  self.id = 12586027
  self.targetRoleId = targetRoleId or nil
end
function CGetRoleModelInfo:marshal(os)
  os:marshalInt64(self.targetRoleId)
end
function CGetRoleModelInfo:unmarshal(os)
  self.targetRoleId = os:unmarshalInt64()
end
function CGetRoleModelInfo:sizepolicy(size)
  return size <= 65535
end
return CGetRoleModelInfo
