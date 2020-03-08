local OctetsStream = require("netio.OctetsStream")
local RMBGiftBagTierInfo = class("RMBGiftBagTierInfo")
function RMBGiftBagTierInfo:ctor(buy_times, award_times, award_timestamp)
  self.buy_times = buy_times or nil
  self.award_times = award_times or nil
  self.award_timestamp = award_timestamp or nil
end
function RMBGiftBagTierInfo:marshal(os)
  os:marshalInt32(self.buy_times)
  os:marshalInt32(self.award_times)
  os:marshalInt64(self.award_timestamp)
end
function RMBGiftBagTierInfo:unmarshal(os)
  self.buy_times = os:unmarshalInt32()
  self.award_times = os:unmarshalInt32()
  self.award_timestamp = os:unmarshalInt64()
end
return RMBGiftBagTierInfo
