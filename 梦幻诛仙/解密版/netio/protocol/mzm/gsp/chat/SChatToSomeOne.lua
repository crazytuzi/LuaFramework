local ChatContent = require("netio.protocol.mzm.gsp.chat.ChatContent")
local SChatToSomeOne = class("SChatToSomeOne")
SChatToSomeOne.TYPEID = 12585217
function SChatToSomeOne:ctor(chatContent, senderId, listenerId)
  self.id = 12585217
  self.chatContent = chatContent or ChatContent.new()
  self.senderId = senderId or nil
  self.listenerId = listenerId or nil
end
function SChatToSomeOne:marshal(os)
  self.chatContent:marshal(os)
  os:marshalInt64(self.senderId)
  os:marshalInt64(self.listenerId)
end
function SChatToSomeOne:unmarshal(os)
  self.chatContent = ChatContent.new()
  self.chatContent:unmarshal(os)
  self.senderId = os:unmarshalInt64()
  self.listenerId = os:unmarshalInt64()
end
function SChatToSomeOne:sizepolicy(size)
  return size <= 65535
end
return SChatToSomeOne
