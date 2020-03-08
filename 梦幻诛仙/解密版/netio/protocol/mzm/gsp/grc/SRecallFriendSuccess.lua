local SRecallFriendSuccess = class("SRecallFriendSuccess")
SRecallFriendSuccess.TYPEID = 12600369
function SRecallFriendSuccess:ctor(zone_id, role_id, open_id, invite_time)
  self.id = 12600369
  self.zone_id = zone_id or nil
  self.role_id = role_id or nil
  self.open_id = open_id or nil
  self.invite_time = invite_time or nil
end
function SRecallFriendSuccess:marshal(os)
  os:marshalInt32(self.zone_id)
  os:marshalInt64(self.role_id)
  os:marshalOctets(self.open_id)
  os:marshalInt32(self.invite_time)
end
function SRecallFriendSuccess:unmarshal(os)
  self.zone_id = os:unmarshalInt32()
  self.role_id = os:unmarshalInt64()
  self.open_id = os:unmarshalOctets()
  self.invite_time = os:unmarshalInt32()
end
function SRecallFriendSuccess:sizepolicy(size)
  return size <= 65535
end
return SRecallFriendSuccess
