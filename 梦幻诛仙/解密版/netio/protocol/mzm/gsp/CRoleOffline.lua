local CRoleOffline = class("CRoleOffline")
CRoleOffline.TYPEID = 12590088
CRoleOffline.LINK_BREAK = 1
CRoleOffline.QUIT_GAME = 2
CRoleOffline.CHANGE_ROLE = 3
CRoleOffline.OTHER_REASON = 4
CRoleOffline.SERVER_SHUT_DOWN = 5
function CRoleOffline:ctor(reason)
  self.id = 12590088
  self.reason = reason or nil
end
function CRoleOffline:marshal(os)
  os:marshalInt32(self.reason)
end
function CRoleOffline:unmarshal(os)
  self.reason = os:unmarshalInt32()
end
function CRoleOffline:sizepolicy(size)
  return size <= 32
end
return CRoleOffline
