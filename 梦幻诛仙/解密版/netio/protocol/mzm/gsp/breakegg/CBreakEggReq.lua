local CBreakEggReq = class("CBreakEggReq")
CBreakEggReq.TYPEID = 12623369
function CBreakEggReq:ctor(activity_id, inviter_id, index)
  self.id = 12623369
  self.activity_id = activity_id or nil
  self.inviter_id = inviter_id or nil
  self.index = index or nil
end
function CBreakEggReq:marshal(os)
  os:marshalInt32(self.activity_id)
  os:marshalInt64(self.inviter_id)
  os:marshalInt32(self.index)
end
function CBreakEggReq:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
  self.inviter_id = os:unmarshalInt64()
  self.index = os:unmarshalInt32()
end
function CBreakEggReq:sizepolicy(size)
  return size <= 65535
end
return CBreakEggReq
