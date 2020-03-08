local SRoleOffline = class("SRoleOffline")
SRoleOffline.TYPEID = 12590101
function SRoleOffline:ctor()
  self.id = 12590101
end
function SRoleOffline:marshal(os)
end
function SRoleOffline:unmarshal(os)
end
function SRoleOffline:sizepolicy(size)
  return size <= 32
end
return SRoleOffline
