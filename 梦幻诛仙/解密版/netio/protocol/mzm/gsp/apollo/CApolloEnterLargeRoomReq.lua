local CApolloEnterLargeRoomReq = class("CApolloEnterLargeRoomReq")
CApolloEnterLargeRoomReq.TYPEID = 12602628
function CApolloEnterLargeRoomReq:ctor(room_type, room_context_id)
  self.id = 12602628
  self.room_type = room_type or nil
  self.room_context_id = room_context_id or nil
end
function CApolloEnterLargeRoomReq:marshal(os)
  os:marshalInt32(self.room_type)
  os:marshalInt64(self.room_context_id)
end
function CApolloEnterLargeRoomReq:unmarshal(os)
  self.room_type = os:unmarshalInt32()
  self.room_context_id = os:unmarshalInt64()
end
function CApolloEnterLargeRoomReq:sizepolicy(size)
  return size <= 65535
end
return CApolloEnterLargeRoomReq
