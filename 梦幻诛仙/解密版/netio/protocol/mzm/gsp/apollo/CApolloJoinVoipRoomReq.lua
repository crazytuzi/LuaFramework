local CApolloJoinVoipRoomReq = class("CApolloJoinVoipRoomReq")
CApolloJoinVoipRoomReq.TYPEID = 12602633
function CApolloJoinVoipRoomReq:ctor(voip_room_type)
  self.id = 12602633
  self.voip_room_type = voip_room_type or nil
end
function CApolloJoinVoipRoomReq:marshal(os)
  os:marshalInt32(self.voip_room_type)
end
function CApolloJoinVoipRoomReq:unmarshal(os)
  self.voip_room_type = os:unmarshalInt32()
end
function CApolloJoinVoipRoomReq:sizepolicy(size)
  return size <= 65535
end
return CApolloJoinVoipRoomReq
