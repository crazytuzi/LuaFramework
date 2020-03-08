local CPublicAnnouncementReq = class("CPublicAnnouncementReq")
CPublicAnnouncementReq.TYPEID = 12589888
function CPublicAnnouncementReq:ctor(announcement)
  self.id = 12589888
  self.announcement = announcement or nil
end
function CPublicAnnouncementReq:marshal(os)
  os:marshalString(self.announcement)
end
function CPublicAnnouncementReq:unmarshal(os)
  self.announcement = os:unmarshalString()
end
function CPublicAnnouncementReq:sizepolicy(size)
  return size <= 65535
end
return CPublicAnnouncementReq
