local SSendRecallFriendSuccess = class("SSendRecallFriendSuccess")
SSendRecallFriendSuccess.TYPEID = 12600358
function SSendRecallFriendSuccess:ctor(zone_id, role_id, open_id)
  self.id = 12600358
  self.zone_id = zone_id or nil
  self.role_id = role_id or nil
  self.open_id = open_id or nil
end
function SSendRecallFriendSuccess:marshal(os)
  os:marshalInt32(self.zone_id)
  os:marshalInt64(self.role_id)
  os:marshalOctets(self.open_id)
end
function SSendRecallFriendSuccess:unmarshal(os)
  self.zone_id = os:unmarshalInt32()
  self.role_id = os:unmarshalInt64()
  self.open_id = os:unmarshalOctets()
end
function SSendRecallFriendSuccess:sizepolicy(size)
  return size <= 65535
end
return SSendRecallFriendSuccess
