local SWarnAddFriendAutoBan = class("SWarnAddFriendAutoBan")
SWarnAddFriendAutoBan.TYPEID = 12587041
function SWarnAddFriendAutoBan:ctor(target_role_id)
  self.id = 12587041
  self.target_role_id = target_role_id or nil
end
function SWarnAddFriendAutoBan:marshal(os)
  os:marshalInt64(self.target_role_id)
end
function SWarnAddFriendAutoBan:unmarshal(os)
  self.target_role_id = os:unmarshalInt64()
end
function SWarnAddFriendAutoBan:sizepolicy(size)
  return size <= 65535
end
return SWarnAddFriendAutoBan
