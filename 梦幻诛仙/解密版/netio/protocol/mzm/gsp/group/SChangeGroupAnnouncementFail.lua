local SChangeGroupAnnouncementFail = class("SChangeGroupAnnouncementFail")
SChangeGroupAnnouncementFail.TYPEID = 12605210
SChangeGroupAnnouncementFail.GROUP_NOT_EXIST = 1
SChangeGroupAnnouncementFail.ROLE_NOT_MASTER = 2
SChangeGroupAnnouncementFail.GROUP_ANNOUNCEMENT_ILLEGAL = 3
SChangeGroupAnnouncementFail.SAME_GROUP_ANNOUNCEMENT = 4
function SChangeGroupAnnouncementFail:ctor(res)
  self.id = 12605210
  self.res = res or nil
end
function SChangeGroupAnnouncementFail:marshal(os)
  os:marshalInt32(self.res)
end
function SChangeGroupAnnouncementFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SChangeGroupAnnouncementFail:sizepolicy(size)
  return size <= 65535
end
return SChangeGroupAnnouncementFail
