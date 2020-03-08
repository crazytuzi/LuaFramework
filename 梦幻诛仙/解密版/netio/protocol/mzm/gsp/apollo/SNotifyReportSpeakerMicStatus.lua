local SNotifyReportSpeakerMicStatus = class("SNotifyReportSpeakerMicStatus")
SNotifyReportSpeakerMicStatus.TYPEID = 12602636
function SNotifyReportSpeakerMicStatus:ctor(room_type, openid, status)
  self.id = 12602636
  self.room_type = room_type or nil
  self.openid = openid or nil
  self.status = status or nil
end
function SNotifyReportSpeakerMicStatus:marshal(os)
  os:marshalInt32(self.room_type)
  os:marshalOctets(self.openid)
  os:marshalUInt8(self.status)
end
function SNotifyReportSpeakerMicStatus:unmarshal(os)
  self.room_type = os:unmarshalInt32()
  self.openid = os:unmarshalOctets()
  self.status = os:unmarshalUInt8()
end
function SNotifyReportSpeakerMicStatus:sizepolicy(size)
  return size <= 65535
end
return SNotifyReportSpeakerMicStatus
