local CPacketFaBaoInChat = class("CPacketFaBaoInChat")
CPacketFaBaoInChat.TYPEID = 12585244
function CPacketFaBaoInChat:ctor(checkedroleid, uuid)
  self.id = 12585244
  self.checkedroleid = checkedroleid or nil
  self.uuid = uuid or nil
end
function CPacketFaBaoInChat:marshal(os)
  os:marshalInt64(self.checkedroleid)
  os:marshalInt64(self.uuid)
end
function CPacketFaBaoInChat:unmarshal(os)
  self.checkedroleid = os:unmarshalInt64()
  self.uuid = os:unmarshalInt64()
end
function CPacketFaBaoInChat:sizepolicy(size)
  return size <= 65535
end
return CPacketFaBaoInChat
