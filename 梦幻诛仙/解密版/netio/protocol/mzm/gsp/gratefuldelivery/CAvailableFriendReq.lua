local CAvailableFriendReq = class("CAvailableFriendReq")
CAvailableFriendReq.TYPEID = 12615684
function CAvailableFriendReq:ctor(activity_id)
  self.id = 12615684
  self.activity_id = activity_id or nil
end
function CAvailableFriendReq:marshal(os)
  os:marshalInt32(self.activity_id)
end
function CAvailableFriendReq:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
end
function CAvailableFriendReq:sizepolicy(size)
  return size <= 65535
end
return CAvailableFriendReq
