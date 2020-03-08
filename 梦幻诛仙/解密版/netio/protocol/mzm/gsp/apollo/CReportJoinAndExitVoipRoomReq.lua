local CReportJoinAndExitVoipRoomReq = class("CReportJoinAndExitVoipRoomReq")
CReportJoinAndExitVoipRoomReq.TYPEID = 12602642
function CReportJoinAndExitVoipRoomReq:ctor(voip_room_type, action)
  self.id = 12602642
  self.voip_room_type = voip_room_type or nil
  self.action = action or nil
end
function CReportJoinAndExitVoipRoomReq:marshal(os)
  os:marshalInt32(self.voip_room_type)
  os:marshalInt32(self.action)
end
function CReportJoinAndExitVoipRoomReq:unmarshal(os)
  self.voip_room_type = os:unmarshalInt32()
  self.action = os:unmarshalInt32()
end
function CReportJoinAndExitVoipRoomReq:sizepolicy(size)
  return size <= 65535
end
return CReportJoinAndExitVoipRoomReq
