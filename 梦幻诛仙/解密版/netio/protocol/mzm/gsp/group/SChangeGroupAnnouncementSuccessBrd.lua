local SChangeGroupAnnouncementSuccessBrd = class("SChangeGroupAnnouncementSuccessBrd")
SChangeGroupAnnouncementSuccessBrd.TYPEID = 12605217
function SChangeGroupAnnouncementSuccessBrd:ctor(groupid, announcement, info_version)
  self.id = 12605217
  self.groupid = groupid or nil
  self.announcement = announcement or nil
  self.info_version = info_version or nil
end
function SChangeGroupAnnouncementSuccessBrd:marshal(os)
  os:marshalInt64(self.groupid)
  os:marshalOctets(self.announcement)
  os:marshalInt64(self.info_version)
end
function SChangeGroupAnnouncementSuccessBrd:unmarshal(os)
  self.groupid = os:unmarshalInt64()
  self.announcement = os:unmarshalOctets()
  self.info_version = os:unmarshalInt64()
end
function SChangeGroupAnnouncementSuccessBrd:sizepolicy(size)
  return size <= 65535
end
return SChangeGroupAnnouncementSuccessBrd
