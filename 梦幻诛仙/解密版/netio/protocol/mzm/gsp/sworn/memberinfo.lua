local OctetsStream = require("netio.OctetsStream")
local memberinfo = class("memberinfo")
function memberinfo:ctor(roleid, level, gender, menpai, name, title)
  self.roleid = roleid or nil
  self.level = level or nil
  self.gender = gender or nil
  self.menpai = menpai or nil
  self.name = name or nil
  self.title = title or nil
end
function memberinfo:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalInt32(self.level)
  os:marshalInt32(self.gender)
  os:marshalInt32(self.menpai)
  os:marshalString(self.name)
  os:marshalString(self.title)
end
function memberinfo:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.level = os:unmarshalInt32()
  self.gender = os:unmarshalInt32()
  self.menpai = os:unmarshalInt32()
  self.name = os:unmarshalString()
  self.title = os:unmarshalString()
end
return memberinfo
