local SMarryRes = class("SMarryRes")
SMarryRes.TYPEID = 12599823
function SMarryRes:ctor(roleid, roleName, level, sessionid)
  self.id = 12599823
  self.roleid = roleid or nil
  self.roleName = roleName or nil
  self.level = level or nil
  self.sessionid = sessionid or nil
end
function SMarryRes:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalString(self.roleName)
  os:marshalInt32(self.level)
  os:marshalInt64(self.sessionid)
end
function SMarryRes:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.roleName = os:unmarshalString()
  self.level = os:unmarshalInt32()
  self.sessionid = os:unmarshalInt64()
end
function SMarryRes:sizepolicy(size)
  return size <= 65535
end
return SMarryRes
