local GreetingCardData = require("netio.protocol.mzm.gsp.greetingcard.GreetingCardData")
local CSendCardReq = class("CSendCardReq")
CSendCardReq.TYPEID = 12616449
function CSendCardReq:ctor(item_key, channel, data)
  self.id = 12616449
  self.item_key = item_key or nil
  self.channel = channel or nil
  self.data = data or GreetingCardData.new()
end
function CSendCardReq:marshal(os)
  os:marshalInt32(self.item_key)
  os:marshalInt32(self.channel)
  self.data:marshal(os)
end
function CSendCardReq:unmarshal(os)
  self.item_key = os:unmarshalInt32()
  self.channel = os:unmarshalInt32()
  self.data = GreetingCardData.new()
  self.data:unmarshal(os)
end
function CSendCardReq:sizepolicy(size)
  return size <= 65535
end
return CSendCardReq
