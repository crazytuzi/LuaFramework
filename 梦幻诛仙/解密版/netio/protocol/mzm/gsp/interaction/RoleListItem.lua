local OctetsStream = require("netio.OctetsStream")
local RoleListItem = class("RoleListItem")
function RoleListItem:ctor(role_id, role_name, role_level, occupation_id, gender, avatar_id, avatar_frame_id)
  self.role_id = role_id or nil
  self.role_name = role_name or nil
  self.role_level = role_level or nil
  self.occupation_id = occupation_id or nil
  self.gender = gender or nil
  self.avatar_id = avatar_id or nil
  self.avatar_frame_id = avatar_frame_id or nil
end
function RoleListItem:marshal(os)
  os:marshalInt64(self.role_id)
  os:marshalOctets(self.role_name)
  os:marshalInt32(self.role_level)
  os:marshalInt32(self.occupation_id)
  os:marshalInt32(self.gender)
  os:marshalInt32(self.avatar_id)
  os:marshalInt32(self.avatar_frame_id)
end
function RoleListItem:unmarshal(os)
  self.role_id = os:unmarshalInt64()
  self.role_name = os:unmarshalOctets()
  self.role_level = os:unmarshalInt32()
  self.occupation_id = os:unmarshalInt32()
  self.gender = os:unmarshalInt32()
  self.avatar_id = os:unmarshalInt32()
  self.avatar_frame_id = os:unmarshalInt32()
end
return RoleListItem
