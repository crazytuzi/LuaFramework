local SApolloExitVoipRoomRsp = class("SApolloExitVoipRoomRsp")
SApolloExitVoipRoomRsp.TYPEID = 12602630
function SApolloExitVoipRoomRsp:ctor(retcode, voip_room_type, room_id, member_id)
  self.id = 12602630
  self.retcode = retcode or nil
  self.voip_room_type = voip_room_type or nil
  self.room_id = room_id or nil
  self.member_id = member_id or nil
end
function SApolloExitVoipRoomRsp:marshal(os)
  os:marshalInt32(self.retcode)
  os:marshalInt32(self.voip_room_type)
  os:marshalInt64(self.room_id)
  os:marshalInt32(self.member_id)
end
function SApolloExitVoipRoomRsp:unmarshal(os)
  self.retcode = os:unmarshalInt32()
  self.voip_room_type = os:unmarshalInt32()
  self.room_id = os:unmarshalInt64()
  self.member_id = os:unmarshalInt32()
end
function SApolloExitVoipRoomRsp:sizepolicy(size)
  return size <= 65535
end
return SApolloExitVoipRoomRsp
