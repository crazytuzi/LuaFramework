local CApolloEnterGlobalLargeRoomReq = class("CApolloEnterGlobalLargeRoomReq")
CApolloEnterGlobalLargeRoomReq.TYPEID = 12602631
function CApolloEnterGlobalLargeRoomReq:ctor(room_type)
  self.id = 12602631
  self.room_type = room_type or nil
end
function CApolloEnterGlobalLargeRoomReq:marshal(os)
  os:marshalInt32(self.room_type)
end
function CApolloEnterGlobalLargeRoomReq:unmarshal(os)
  self.room_type = os:unmarshalInt32()
end
function CApolloEnterGlobalLargeRoomReq:sizepolicy(size)
  return size <= 65535
end
return CApolloEnterGlobalLargeRoomReq
