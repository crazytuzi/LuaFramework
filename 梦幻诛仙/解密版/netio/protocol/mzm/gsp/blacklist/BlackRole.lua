local OctetsStream = require("netio.OctetsStream")
local BlackRole = class("BlackRole")
BlackRole.ST_OFFLINE = 0
BlackRole.ST_ONLINE = 1
function BlackRole:ctor(roleid, level, name, menpai, gender, status, avatarid, avatar_frame)
  self.roleid = roleid or nil
  self.level = level or nil
  self.name = name or nil
  self.menpai = menpai or nil
  self.gender = gender or nil
  self.status = status or nil
  self.avatarid = avatarid or nil
  self.avatar_frame = avatar_frame or nil
end
function BlackRole:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalInt32(self.level)
  os:marshalString(self.name)
  os:marshalInt32(self.menpai)
  os:marshalInt32(self.gender)
  os:marshalInt32(self.status)
  os:marshalInt32(self.avatarid)
  os:marshalInt32(self.avatar_frame)
end
function BlackRole:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.level = os:unmarshalInt32()
  self.name = os:unmarshalString()
  self.menpai = os:unmarshalInt32()
  self.gender = os:unmarshalInt32()
  self.status = os:unmarshalInt32()
  self.avatarid = os:unmarshalInt32()
  self.avatar_frame = os:unmarshalInt32()
end
return BlackRole
