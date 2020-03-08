local OctetsStream = require("netio.OctetsStream")
local RoleInfo = class("RoleInfo")
function RoleInfo:ctor(roleid, role_name, occupation, gender, level, avatarid, avatar_frameid)
  self.roleid = roleid or nil
  self.role_name = role_name or nil
  self.occupation = occupation or nil
  self.gender = gender or nil
  self.level = level or nil
  self.avatarid = avatarid or nil
  self.avatar_frameid = avatar_frameid or nil
end
function RoleInfo:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalOctets(self.role_name)
  os:marshalInt32(self.occupation)
  os:marshalInt32(self.gender)
  os:marshalInt32(self.level)
  os:marshalInt32(self.avatarid)
  os:marshalInt32(self.avatar_frameid)
end
function RoleInfo:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.role_name = os:unmarshalOctets()
  self.occupation = os:unmarshalInt32()
  self.gender = os:unmarshalInt32()
  self.level = os:unmarshalInt32()
  self.avatarid = os:unmarshalInt32()
  self.avatar_frameid = os:unmarshalInt32()
end
return RoleInfo
