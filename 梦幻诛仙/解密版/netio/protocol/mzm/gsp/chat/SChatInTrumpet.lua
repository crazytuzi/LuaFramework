local ChatContent = require("netio.protocol.mzm.gsp.chat.ChatContent")
local SChatInTrumpet = class("SChatInTrumpet")
SChatInTrumpet.TYPEID = 12585274
function SChatInTrumpet:ctor(trumpet_cfg_id, chatContent)
  self.id = 12585274
  self.trumpet_cfg_id = trumpet_cfg_id or nil
  self.chatContent = chatContent or ChatContent.new()
end
function SChatInTrumpet:marshal(os)
  os:marshalInt32(self.trumpet_cfg_id)
  self.chatContent:marshal(os)
end
function SChatInTrumpet:unmarshal(os)
  self.trumpet_cfg_id = os:unmarshalInt32()
  self.chatContent = ChatContent.new()
  self.chatContent:unmarshal(os)
end
function SChatInTrumpet:sizepolicy(size)
  return size <= 65535
end
return SChatInTrumpet
