local ChatContent = require("netio.protocol.mzm.gsp.chat.ChatContent")
local SSendFail = class("SSendFail")
SSendFail.TYPEID = 12585231
function SSendFail:ctor(senderid, listenerId, contentType, channelType, chatContent, reason)
  self.id = 12585231
  self.senderid = senderid or nil
  self.listenerId = listenerId or nil
  self.contentType = contentType or nil
  self.channelType = channelType or nil
  self.chatContent = chatContent or ChatContent.new()
  self.reason = reason or nil
end
function SSendFail:marshal(os)
  os:marshalInt64(self.senderid)
  os:marshalInt64(self.listenerId)
  os:marshalInt32(self.contentType)
  os:marshalInt32(self.channelType)
  self.chatContent:marshal(os)
  os:marshalInt32(self.reason)
end
function SSendFail:unmarshal(os)
  self.senderid = os:unmarshalInt64()
  self.listenerId = os:unmarshalInt64()
  self.contentType = os:unmarshalInt32()
  self.channelType = os:unmarshalInt32()
  self.chatContent = ChatContent.new()
  self.chatContent:unmarshal(os)
  self.reason = os:unmarshalInt32()
end
function SSendFail:sizepolicy(size)
  return size <= 65535
end
return SSendFail
