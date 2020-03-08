local CQueryNoticeContent = class("CQueryNoticeContent")
CQueryNoticeContent.TYPEID = 12601104
function CQueryNoticeContent:ctor(noticeId)
  self.id = 12601104
  self.noticeId = noticeId or nil
end
function CQueryNoticeContent:marshal(os)
  os:marshalInt64(self.noticeId)
end
function CQueryNoticeContent:unmarshal(os)
  self.noticeId = os:unmarshalInt64()
end
function CQueryNoticeContent:sizepolicy(size)
  return size <= 65535
end
return CQueryNoticeContent
