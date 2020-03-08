local CRecallFriendReq = class("CRecallFriendReq")
CRecallFriendReq.TYPEID = 12600370
function CRecallFriendReq:ctor(zone_id, role_id, open_id)
  self.id = 12600370
  self.zone_id = zone_id or nil
  self.role_id = role_id or nil
  self.open_id = open_id or nil
end
function CRecallFriendReq:marshal(os)
  os:marshalInt32(self.zone_id)
  os:marshalInt64(self.role_id)
  os:marshalOctets(self.open_id)
end
function CRecallFriendReq:unmarshal(os)
  self.zone_id = os:unmarshalInt32()
  self.role_id = os:unmarshalInt64()
  self.open_id = os:unmarshalOctets()
end
function CRecallFriendReq:sizepolicy(size)
  return size <= 65535
end
return CRecallFriendReq
