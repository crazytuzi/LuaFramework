local CRoleKeepAliveNotice = class("CRoleKeepAliveNotice")
CRoleKeepAliveNotice.TYPEID = 12588338
function CRoleKeepAliveNotice:ctor()
  self.id = 12588338
end
function CRoleKeepAliveNotice:marshal(os)
end
function CRoleKeepAliveNotice:unmarshal(os)
end
function CRoleKeepAliveNotice:sizepolicy(size)
  return size <= 65535
end
return CRoleKeepAliveNotice
