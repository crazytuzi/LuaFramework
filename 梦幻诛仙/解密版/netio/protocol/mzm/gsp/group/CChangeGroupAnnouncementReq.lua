local CChangeGroupAnnouncementReq = class("CChangeGroupAnnouncementReq")
CChangeGroupAnnouncementReq.TYPEID = 12605195
function CChangeGroupAnnouncementReq:ctor(groupid, announcement)
  self.id = 12605195
  self.groupid = groupid or nil
  self.announcement = announcement or nil
end
function CChangeGroupAnnouncementReq:marshal(os)
  os:marshalInt64(self.groupid)
  os:marshalOctets(self.announcement)
end
function CChangeGroupAnnouncementReq:unmarshal(os)
  self.groupid = os:unmarshalInt64()
  self.announcement = os:unmarshalOctets()
end
function CChangeGroupAnnouncementReq:sizepolicy(size)
  return size <= 65535
end
return CChangeGroupAnnouncementReq
