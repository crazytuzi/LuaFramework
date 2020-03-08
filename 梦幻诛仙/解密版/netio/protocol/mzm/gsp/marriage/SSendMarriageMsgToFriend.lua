local SSendMarriageMsgToFriend = class("SSendMarriageMsgToFriend")
SSendMarriageMsgToFriend.TYPEID = 12599811
function SSendMarriageMsgToFriend:ctor(roleid, roleidAName, roleidBName, level, timeSec)
  self.id = 12599811
  self.roleid = roleid or nil
  self.roleidAName = roleidAName or nil
  self.roleidBName = roleidBName or nil
  self.level = level or nil
  self.timeSec = timeSec or nil
end
function SSendMarriageMsgToFriend:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalString(self.roleidAName)
  os:marshalString(self.roleidBName)
  os:marshalInt32(self.level)
  os:marshalInt32(self.timeSec)
end
function SSendMarriageMsgToFriend:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.roleidAName = os:unmarshalString()
  self.roleidBName = os:unmarshalString()
  self.level = os:unmarshalInt32()
  self.timeSec = os:unmarshalInt32()
end
function SSendMarriageMsgToFriend:sizepolicy(size)
  return size <= 65535
end
return SSendMarriageMsgToFriend
