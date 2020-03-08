local SSynOfflineChatContents = class("SSynOfflineChatContents")
SSynOfflineChatContents.TYPEID = 12585275
function SSynOfflineChatContents:ctor(channel_type, ownerid, contents)
  self.id = 12585275
  self.channel_type = channel_type or nil
  self.ownerid = ownerid or nil
  self.contents = contents or {}
end
function SSynOfflineChatContents:marshal(os)
  os:marshalInt32(self.channel_type)
  os:marshalInt64(self.ownerid)
  os:marshalCompactUInt32(table.getn(self.contents))
  for _, v in ipairs(self.contents) do
    os:marshalOctets(v)
  end
end
function SSynOfflineChatContents:unmarshal(os)
  self.channel_type = os:unmarshalInt32()
  self.ownerid = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalOctets()
    table.insert(self.contents, v)
  end
end
function SSynOfflineChatContents:sizepolicy(size)
  return size <= 65535
end
return SSynOfflineChatContents
