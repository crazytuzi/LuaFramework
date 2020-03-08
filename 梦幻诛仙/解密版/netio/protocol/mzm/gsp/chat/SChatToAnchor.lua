local SChatToAnchor = class("SChatToAnchor")
SChatToAnchor.TYPEID = 12585242
function SChatToAnchor:ctor(senderZoneId, senderRoomType, chatContent)
  self.id = 12585242
  self.senderZoneId = senderZoneId or nil
  self.senderRoomType = senderRoomType or nil
  self.chatContent = chatContent or nil
end
function SChatToAnchor:marshal(os)
  os:marshalInt32(self.senderZoneId)
  os:marshalInt32(self.senderRoomType)
  os:marshalOctets(self.chatContent)
end
function SChatToAnchor:unmarshal(os)
  self.senderZoneId = os:unmarshalInt32()
  self.senderRoomType = os:unmarshalInt32()
  self.chatContent = os:unmarshalOctets()
end
function SChatToAnchor:sizepolicy(size)
  return size <= 65535
end
return SChatToAnchor
