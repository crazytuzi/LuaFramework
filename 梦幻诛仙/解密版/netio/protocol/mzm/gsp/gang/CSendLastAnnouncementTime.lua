local CSendLastAnnouncementTime = class("CSendLastAnnouncementTime")
CSendLastAnnouncementTime.TYPEID = 12589901
function CSendLastAnnouncementTime:ctor(timestamp)
  self.id = 12589901
  self.timestamp = timestamp or nil
end
function CSendLastAnnouncementTime:marshal(os)
  os:marshalInt64(self.timestamp)
end
function CSendLastAnnouncementTime:unmarshal(os)
  self.timestamp = os:unmarshalInt64()
end
function CSendLastAnnouncementTime:sizepolicy(size)
  return size <= 65535
end
return CSendLastAnnouncementTime
