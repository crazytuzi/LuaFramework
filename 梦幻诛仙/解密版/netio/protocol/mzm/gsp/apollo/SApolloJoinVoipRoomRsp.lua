local VoipRoomUserAccess = require("netio.protocol.mzm.gsp.apollo.VoipRoomUserAccess")
local SApolloJoinVoipRoomRsp = class("SApolloJoinVoipRoomRsp")
SApolloJoinVoipRoomRsp.TYPEID = 12602627
function SApolloJoinVoipRoomRsp:ctor(retcode, voip_room_type, room_id, user_access)
  self.id = 12602627
  self.retcode = retcode or nil
  self.voip_room_type = voip_room_type or nil
  self.room_id = room_id or nil
  self.user_access = user_access or VoipRoomUserAccess.new()
end
function SApolloJoinVoipRoomRsp:marshal(os)
  os:marshalInt32(self.retcode)
  os:marshalInt32(self.voip_room_type)
  os:marshalInt64(self.room_id)
  self.user_access:marshal(os)
end
function SApolloJoinVoipRoomRsp:unmarshal(os)
  self.retcode = os:unmarshalInt32()
  self.voip_room_type = os:unmarshalInt32()
  self.room_id = os:unmarshalInt64()
  self.user_access = VoipRoomUserAccess.new()
  self.user_access:unmarshal(os)
end
function SApolloJoinVoipRoomRsp:sizepolicy(size)
  return size <= 65535
end
return SApolloJoinVoipRoomRsp
