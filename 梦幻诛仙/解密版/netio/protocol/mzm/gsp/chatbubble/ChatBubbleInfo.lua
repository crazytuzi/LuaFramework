local OctetsStream = require("netio.OctetsStream")
local ChatBubbleInfo = class("ChatBubbleInfo")
ChatBubbleInfo.ON = 1
ChatBubbleInfo.OFF = 2
function ChatBubbleInfo:ctor(isOn, chatBubbleCfgId, expireTimeStamp)
  self.isOn = isOn or nil
  self.chatBubbleCfgId = chatBubbleCfgId or nil
  self.expireTimeStamp = expireTimeStamp or nil
end
function ChatBubbleInfo:marshal(os)
  os:marshalInt32(self.isOn)
  os:marshalInt32(self.chatBubbleCfgId)
  os:marshalInt64(self.expireTimeStamp)
end
function ChatBubbleInfo:unmarshal(os)
  self.isOn = os:unmarshalInt32()
  self.chatBubbleCfgId = os:unmarshalInt32()
  self.expireTimeStamp = os:unmarshalInt64()
end
return ChatBubbleInfo
