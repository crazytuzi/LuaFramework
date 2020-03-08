local OctetsStream = require("netio.OctetsStream")
local LuckyStarAwardInfo = class("LuckyStarAwardInfo")
function LuckyStarAwardInfo:ctor(lucky_star_gift_cfg_id, has_buy_times)
  self.lucky_star_gift_cfg_id = lucky_star_gift_cfg_id or nil
  self.has_buy_times = has_buy_times or nil
end
function LuckyStarAwardInfo:marshal(os)
  os:marshalInt32(self.lucky_star_gift_cfg_id)
  os:marshalInt32(self.has_buy_times)
end
function LuckyStarAwardInfo:unmarshal(os)
  self.lucky_star_gift_cfg_id = os:unmarshalInt32()
  self.has_buy_times = os:unmarshalInt32()
end
return LuckyStarAwardInfo
