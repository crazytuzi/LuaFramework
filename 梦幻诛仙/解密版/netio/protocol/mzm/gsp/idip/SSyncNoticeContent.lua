local SSyncNoticeContent = class("SSyncNoticeContent")
SSyncNoticeContent.TYPEID = 12601103
function SSyncNoticeContent:ctor(noticeId, noticeContent)
  self.id = 12601103
  self.noticeId = noticeId or nil
  self.noticeContent = noticeContent or nil
end
function SSyncNoticeContent:marshal(os)
  os:marshalInt64(self.noticeId)
  os:marshalOctets(self.noticeContent)
end
function SSyncNoticeContent:unmarshal(os)
  self.noticeId = os:unmarshalInt64()
  self.noticeContent = os:unmarshalOctets()
end
function SSyncNoticeContent:sizepolicy(size)
  return size <= 65535
end
return SSyncNoticeContent
