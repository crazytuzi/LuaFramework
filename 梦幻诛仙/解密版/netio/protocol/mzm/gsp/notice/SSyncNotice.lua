local SSyncNotice = class("SSyncNotice")
SSyncNotice.TYPEID = 12583937
function SSyncNotice:ctor(title, content, timestamp)
  self.id = 12583937
  self.title = title or nil
  self.content = content or nil
  self.timestamp = timestamp or nil
end
function SSyncNotice:marshal(os)
  os:marshalString(self.title)
  os:marshalString(self.content)
  os:marshalInt64(self.timestamp)
end
function SSyncNotice:unmarshal(os)
  self.title = os:unmarshalString()
  self.content = os:unmarshalString()
  self.timestamp = os:unmarshalInt64()
end
function SSyncNotice:sizepolicy(size)
  return size <= 65535
end
return SSyncNotice
