local SSyncMemberOffline = class("SSyncMemberOffline")
SSyncMemberOffline.TYPEID = 12589842
function SSyncMemberOffline:ctor(roleId)
  self.id = 12589842
  self.roleId = roleId or nil
end
function SSyncMemberOffline:marshal(os)
  os:marshalInt64(self.roleId)
end
function SSyncMemberOffline:unmarshal(os)
  self.roleId = os:unmarshalInt64()
end
function SSyncMemberOffline:sizepolicy(size)
  return size <= 65535
end
return SSyncMemberOffline
