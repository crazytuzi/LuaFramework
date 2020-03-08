local SNotifyKillEvent = class("SNotifyKillEvent")
SNotifyKillEvent.TYPEID = 12629266
function SNotifyKillEvent:ctor(killer_role_id, killer_avatar_id, killer_avatar_frame_id, killed_role_id, killed_avatar_id, killed_avatar_frame_id, position_x, position_y)
  self.id = 12629266
  self.killer_role_id = killer_role_id or nil
  self.killer_avatar_id = killer_avatar_id or nil
  self.killer_avatar_frame_id = killer_avatar_frame_id or nil
  self.killed_role_id = killed_role_id or nil
  self.killed_avatar_id = killed_avatar_id or nil
  self.killed_avatar_frame_id = killed_avatar_frame_id or nil
  self.position_x = position_x or nil
  self.position_y = position_y or nil
end
function SNotifyKillEvent:marshal(os)
  os:marshalInt64(self.killer_role_id)
  os:marshalInt32(self.killer_avatar_id)
  os:marshalInt32(self.killer_avatar_frame_id)
  os:marshalInt64(self.killed_role_id)
  os:marshalInt32(self.killed_avatar_id)
  os:marshalInt32(self.killed_avatar_frame_id)
  os:marshalInt32(self.position_x)
  os:marshalInt32(self.position_y)
end
function SNotifyKillEvent:unmarshal(os)
  self.killer_role_id = os:unmarshalInt64()
  self.killer_avatar_id = os:unmarshalInt32()
  self.killer_avatar_frame_id = os:unmarshalInt32()
  self.killed_role_id = os:unmarshalInt64()
  self.killed_avatar_id = os:unmarshalInt32()
  self.killed_avatar_frame_id = os:unmarshalInt32()
  self.position_x = os:unmarshalInt32()
  self.position_y = os:unmarshalInt32()
end
function SNotifyKillEvent:sizepolicy(size)
  return size <= 65535
end
return SNotifyKillEvent
