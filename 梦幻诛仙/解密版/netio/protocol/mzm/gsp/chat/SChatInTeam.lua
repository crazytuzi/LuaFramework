local ChatContent = require("netio.protocol.mzm.gsp.chat.ChatContent")
local SChatInTeam = class("SChatInTeam")
SChatInTeam.TYPEID = 12585218
function SChatInTeam:ctor(chatContent, position)
  self.id = 12585218
  self.chatContent = chatContent or ChatContent.new()
  self.position = position or nil
end
function SChatInTeam:marshal(os)
  self.chatContent:marshal(os)
  os:marshalInt32(self.position)
end
function SChatInTeam:unmarshal(os)
  self.chatContent = ChatContent.new()
  self.chatContent:unmarshal(os)
  self.position = os:unmarshalInt32()
end
function SChatInTeam:sizepolicy(size)
  return size <= 65535
end
return SChatInTeam
