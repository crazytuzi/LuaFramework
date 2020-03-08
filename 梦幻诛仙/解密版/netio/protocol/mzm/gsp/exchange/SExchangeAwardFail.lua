local SExchangeAwardFail = class("SExchangeAwardFail")
SExchangeAwardFail.TYPEID = 12604165
SExchangeAwardFail.EXCHANGE_TIME_TO_LIMIT = 0
SExchangeAwardFail.NEED_ITEM_NOT_ENOUGH = 1
SExchangeAwardFail.AWARD_FAIL = 2
function SExchangeAwardFail:ctor(activity_cfg_id, sort_id, res, exchange_times)
  self.id = 12604165
  self.activity_cfg_id = activity_cfg_id or nil
  self.sort_id = sort_id or nil
  self.res = res or nil
  self.exchange_times = exchange_times or nil
end
function SExchangeAwardFail:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.sort_id)
  os:marshalInt32(self.res)
  os:marshalInt32(self.exchange_times)
end
function SExchangeAwardFail:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.sort_id = os:unmarshalInt32()
  self.res = os:unmarshalInt32()
  self.exchange_times = os:unmarshalInt32()
end
function SExchangeAwardFail:sizepolicy(size)
  return size <= 65535
end
return SExchangeAwardFail
