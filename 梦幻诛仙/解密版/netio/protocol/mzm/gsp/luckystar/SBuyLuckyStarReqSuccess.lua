local SBuyLuckyStarReqSuccess = class("SBuyLuckyStarReqSuccess")
SBuyLuckyStarReqSuccess.TYPEID = 12608513
function SBuyLuckyStarReqSuccess:ctor(activity_cfg_id, lucky_star_gift_cfg_id, has_buy_times)
  self.id = 12608513
  self.activity_cfg_id = activity_cfg_id or nil
  self.lucky_star_gift_cfg_id = lucky_star_gift_cfg_id or nil
  self.has_buy_times = has_buy_times or nil
end
function SBuyLuckyStarReqSuccess:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.lucky_star_gift_cfg_id)
  os:marshalInt32(self.has_buy_times)
end
function SBuyLuckyStarReqSuccess:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.lucky_star_gift_cfg_id = os:unmarshalInt32()
  self.has_buy_times = os:unmarshalInt32()
end
function SBuyLuckyStarReqSuccess:sizepolicy(size)
  return size <= 65535
end
return SBuyLuckyStarReqSuccess
