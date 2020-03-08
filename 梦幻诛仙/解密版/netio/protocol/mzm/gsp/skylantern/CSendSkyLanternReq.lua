local GreetingCardData = require("netio.protocol.mzm.gsp.greetingcard.GreetingCardData")
local CSendSkyLanternReq = class("CSendSkyLanternReq")
CSendSkyLanternReq.TYPEID = 12624129
function CSendSkyLanternReq:ctor(activity_id, channel, data)
  self.id = 12624129
  self.activity_id = activity_id or nil
  self.channel = channel or nil
  self.data = data or GreetingCardData.new()
end
function CSendSkyLanternReq:marshal(os)
  os:marshalInt32(self.activity_id)
  os:marshalInt32(self.channel)
  self.data:marshal(os)
end
function CSendSkyLanternReq:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
  self.channel = os:unmarshalInt32()
  self.data = GreetingCardData.new()
  self.data:unmarshal(os)
end
function CSendSkyLanternReq:sizepolicy(size)
  return size <= 65535
end
return CSendSkyLanternReq
