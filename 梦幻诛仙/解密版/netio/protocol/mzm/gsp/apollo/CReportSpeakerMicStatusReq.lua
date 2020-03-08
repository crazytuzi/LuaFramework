local CReportSpeakerMicStatusReq = class("CReportSpeakerMicStatusReq")
CReportSpeakerMicStatusReq.TYPEID = 12602635
function CReportSpeakerMicStatusReq:ctor(room_type, status)
  self.id = 12602635
  self.room_type = room_type or nil
  self.status = status or nil
end
function CReportSpeakerMicStatusReq:marshal(os)
  os:marshalInt32(self.room_type)
  os:marshalUInt8(self.status)
end
function CReportSpeakerMicStatusReq:unmarshal(os)
  self.room_type = os:unmarshalInt32()
  self.status = os:unmarshalUInt8()
end
function CReportSpeakerMicStatusReq:sizepolicy(size)
  return size <= 65535
end
return CReportSpeakerMicStatusReq
