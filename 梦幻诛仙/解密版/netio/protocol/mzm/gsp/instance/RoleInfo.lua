local OctetsStream = require("netio.OctetsStream")
local RoleInfo = class("RoleInfo")
function RoleInfo:ctor(roleid, roleName, occupation, gender, avatarid, avatar_frame_id)
  self.roleid = roleid or nil
  self.roleName = roleName or nil
  self.occupation = occupation or nil
  self.gender = gender or nil
  self.avatarid = avatarid or nil
  self.avatar_frame_id = avatar_frame_id or nil
end
function RoleInfo:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalString(self.roleName)
  os:marshalInt32(self.occupation)
  os:marshalInt32(self.gender)
  os:marshalInt32(self.avatarid)
  os:marshalInt32(self.avatar_frame_id)
end
function RoleInfo:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.roleName = os:unmarshalString()
  self.occupation = os:unmarshalInt32()
  self.gender = os:unmarshalInt32()
  self.avatarid = os:unmarshalInt32()
  self.avatar_frame_id = os:unmarshalInt32()
end
return RoleInfo
