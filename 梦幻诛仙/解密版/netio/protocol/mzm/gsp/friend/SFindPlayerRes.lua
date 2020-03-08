local SFindPlayerRes = class("SFindPlayerRes")
SFindPlayerRes.TYPEID = 12587029
function SFindPlayerRes:ctor(roleId, roleName, roleLevel, occupationId, sex, onlineStatus, friendSet, avatarId, avatarFrameId)
  self.id = 12587029
  self.roleId = roleId or nil
  self.roleName = roleName or nil
  self.roleLevel = roleLevel or nil
  self.occupationId = occupationId or nil
  self.sex = sex or nil
  self.onlineStatus = onlineStatus or nil
  self.friendSet = friendSet or nil
  self.avatarId = avatarId or nil
  self.avatarFrameId = avatarFrameId or nil
end
function SFindPlayerRes:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalString(self.roleName)
  os:marshalInt32(self.roleLevel)
  os:marshalInt32(self.occupationId)
  os:marshalInt32(self.sex)
  os:marshalInt32(self.onlineStatus)
  os:marshalInt32(self.friendSet)
  os:marshalInt32(self.avatarId)
  os:marshalInt32(self.avatarFrameId)
end
function SFindPlayerRes:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.roleName = os:unmarshalString()
  self.roleLevel = os:unmarshalInt32()
  self.occupationId = os:unmarshalInt32()
  self.sex = os:unmarshalInt32()
  self.onlineStatus = os:unmarshalInt32()
  self.friendSet = os:unmarshalInt32()
  self.avatarId = os:unmarshalInt32()
  self.avatarFrameId = os:unmarshalInt32()
end
function SFindPlayerRes:sizepolicy(size)
  return size <= 65535
end
return SFindPlayerRes
