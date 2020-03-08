local OctetsStream = require("netio.OctetsStream")
local ExchangeUseItemInfo = class("ExchangeUseItemInfo")
function ExchangeUseItemInfo:ctor(exchange_times, daily_exchange_times)
  self.exchange_times = exchange_times or nil
  self.daily_exchange_times = daily_exchange_times or nil
end
function ExchangeUseItemInfo:marshal(os)
  os:marshalInt32(self.exchange_times)
  os:marshalInt32(self.daily_exchange_times)
end
function ExchangeUseItemInfo:unmarshal(os)
  self.exchange_times = os:unmarshalInt32()
  self.daily_exchange_times = os:unmarshalInt32()
end
return ExchangeUseItemInfo
