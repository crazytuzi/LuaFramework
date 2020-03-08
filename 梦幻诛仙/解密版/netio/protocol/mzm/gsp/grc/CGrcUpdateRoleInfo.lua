local CGrcUpdateRoleInfo = class("CGrcUpdateRoleInfo")
CGrcUpdateRoleInfo.TYPEID = 12600329
function CGrcUpdateRoleInfo:ctor()
  self.id = 12600329
end
function CGrcUpdateRoleInfo:marshal(os)
end
function CGrcUpdateRoleInfo:unmarshal(os)
end
function CGrcUpdateRoleInfo:sizepolicy(size)
  return size <= 65535
end
return CGrcUpdateRoleInfo
