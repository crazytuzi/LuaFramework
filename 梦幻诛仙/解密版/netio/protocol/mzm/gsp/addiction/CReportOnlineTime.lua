local CReportOnlineTime = class("CReportOnlineTime")
CReportOnlineTime.TYPEID = 12608004
function CReportOnlineTime:ctor(status)
  self.id = 12608004
  self.status = status or nil
end
function CReportOnlineTime:marshal(os)
  os:marshalUInt8(self.status)
end
function CReportOnlineTime:unmarshal(os)
  self.status = os:unmarshalUInt8()
end
function CReportOnlineTime:sizepolicy(size)
  return size <= 65535
end
return CReportOnlineTime
