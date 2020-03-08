local GreetingCardData = require("netio.protocol.mzm.gsp.greetingcard.GreetingCardData")
local SenderData = require("netio.protocol.mzm.gsp.greetingcard.SenderData")
local SSendCardBroadcast = class("SSendCardBroadcast")
SSendCardBroadcast.TYPEID = 12616450
function SSendCardBroadcast:ctor(channel, data, senderData)
  self.id = 12616450
  self.channel = channel or nil
  self.data = data or GreetingCardData.new()
  self.senderData = senderData or SenderData.new()
end
function SSendCardBroadcast:marshal(os)
  os:marshalInt32(self.channel)
  self.data:marshal(os)
  self.senderData:marshal(os)
end
function SSendCardBroadcast:unmarshal(os)
  self.channel = os:unmarshalInt32()
  self.data = GreetingCardData.new()
  self.data:unmarshal(os)
  self.senderData = SenderData.new()
  self.senderData:unmarshal(os)
end
function SSendCardBroadcast:sizepolicy(size)
  return size <= 65535
end
return SSendCardBroadcast
