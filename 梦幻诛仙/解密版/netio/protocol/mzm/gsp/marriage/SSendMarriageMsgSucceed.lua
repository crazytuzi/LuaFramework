local SSendMarriageMsgSucceed = class("SSendMarriageMsgSucceed")
SSendMarriageMsgSucceed.TYPEID = 12599822
function SSendMarriageMsgSucceed:ctor(roleid, roleidName, level, timeSec)
  self.id = 12599822
  self.roleid = roleid or nil
  self.roleidName = roleidName or nil
  self.level = level or nil
  self.timeSec = timeSec or nil
end
function SSendMarriageMsgSucceed:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalString(self.roleidName)
  os:marshalInt32(self.level)
  os:marshalInt32(self.timeSec)
end
function SSendMarriageMsgSucceed:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.roleidName = os:unmarshalString()
  self.level = os:unmarshalInt32()
  self.timeSec = os:unmarshalInt32()
end
function SSendMarriageMsgSucceed:sizepolicy(size)
  return size <= 65535
end
return SSendMarriageMsgSucceed
