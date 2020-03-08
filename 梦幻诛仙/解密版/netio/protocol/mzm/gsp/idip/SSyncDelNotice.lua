local SSyncDelNotice = class("SSyncDelNotice")
SSyncDelNotice.TYPEID = 12601101
function SSyncDelNotice:ctor(noticeId)
  self.id = 12601101
  self.noticeId = noticeId or nil
end
function SSyncDelNotice:marshal(os)
  os:marshalInt64(self.noticeId)
end
function SSyncDelNotice:unmarshal(os)
  self.noticeId = os:unmarshalInt64()
end
function SSyncDelNotice:sizepolicy(size)
  return size <= 65535
end
return SSyncDelNotice
