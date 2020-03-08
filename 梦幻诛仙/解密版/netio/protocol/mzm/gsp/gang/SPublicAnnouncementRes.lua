local SPublicAnnouncementRes = class("SPublicAnnouncementRes")
SPublicAnnouncementRes.TYPEID = 12589893
function SPublicAnnouncementRes:ctor(costVigor)
  self.id = 12589893
  self.costVigor = costVigor or nil
end
function SPublicAnnouncementRes:marshal(os)
  os:marshalInt32(self.costVigor)
end
function SPublicAnnouncementRes:unmarshal(os)
  self.costVigor = os:unmarshalInt32()
end
function SPublicAnnouncementRes:sizepolicy(size)
  return size <= 65535
end
return SPublicAnnouncementRes
