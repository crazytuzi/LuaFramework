local CBreakEggInviteReq = class("CBreakEggInviteReq")
CBreakEggInviteReq.TYPEID = 12623361
function CBreakEggInviteReq:ctor(activity_id)
  self.id = 12623361
  self.activity_id = activity_id or nil
end
function CBreakEggInviteReq:marshal(os)
  os:marshalInt32(self.activity_id)
end
function CBreakEggInviteReq:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
end
function CBreakEggInviteReq:sizepolicy(size)
  return size <= 65535
end
return CBreakEggInviteReq
