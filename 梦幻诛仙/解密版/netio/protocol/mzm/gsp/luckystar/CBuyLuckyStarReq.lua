local CBuyLuckyStarReq = class("CBuyLuckyStarReq")
CBuyLuckyStarReq.TYPEID = 12608516
function CBuyLuckyStarReq:ctor(activity_cfg_id, lucky_star_gift_cfg_id, currency_client_value, buy_times_req)
  self.id = 12608516
  self.activity_cfg_id = activity_cfg_id or nil
  self.lucky_star_gift_cfg_id = lucky_star_gift_cfg_id or nil
  self.currency_client_value = currency_client_value or nil
  self.buy_times_req = buy_times_req or nil
end
function CBuyLuckyStarReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.lucky_star_gift_cfg_id)
  os:marshalInt64(self.currency_client_value)
  os:marshalInt32(self.buy_times_req)
end
function CBuyLuckyStarReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.lucky_star_gift_cfg_id = os:unmarshalInt32()
  self.currency_client_value = os:unmarshalInt64()
  self.buy_times_req = os:unmarshalInt32()
end
function CBuyLuckyStarReq:sizepolicy(size)
  return size <= 65535
end
return CBuyLuckyStarReq
