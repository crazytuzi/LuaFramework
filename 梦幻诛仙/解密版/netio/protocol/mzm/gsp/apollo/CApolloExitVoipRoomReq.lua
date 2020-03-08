local CApolloExitVoipRoomReq = class("CApolloExitVoipRoomReq")
CApolloExitVoipRoomReq.TYPEID = 12602632
function CApolloExitVoipRoomReq:ctor(voip_room_type)
  self.id = 12602632
  self.voip_room_type = voip_room_type or nil
end
function CApolloExitVoipRoomReq:marshal(os)
  os:marshalInt32(self.voip_room_type)
end
function CApolloExitVoipRoomReq:unmarshal(os)
  self.voip_room_type = os:unmarshalInt32()
end
function CApolloExitVoipRoomReq:sizepolicy(size)
  return size <= 65535
end
return CApolloExitVoipRoomReq
