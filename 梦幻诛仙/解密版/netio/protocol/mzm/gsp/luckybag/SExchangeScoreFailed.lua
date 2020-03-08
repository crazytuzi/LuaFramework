local SExchangeScoreFailed = class("SExchangeScoreFailed")
SExchangeScoreFailed.TYPEID = 12607494
SExchangeScoreFailed.ERROR_SCORE_NOT_ENOUGH = -1
SExchangeScoreFailed.ERROR_BAG_FULL = -2
SExchangeScoreFailed.ERROR_CAN_NOT_JOIN_ACTIVITY = -3
SExchangeScoreFailed.ERROR_BAG_NOT_ENOUGH = -4
function SExchangeScoreFailed:ctor(retcode, lucky_bag_score_cfgid, client_score, num)
  self.id = 12607494
  self.retcode = retcode or nil
  self.lucky_bag_score_cfgid = lucky_bag_score_cfgid or nil
  self.client_score = client_score or nil
  self.num = num or nil
end
function SExchangeScoreFailed:marshal(os)
  os:marshalInt32(self.retcode)
  os:marshalInt32(self.lucky_bag_score_cfgid)
  os:marshalInt32(self.client_score)
  os:marshalInt32(self.num)
end
function SExchangeScoreFailed:unmarshal(os)
  self.retcode = os:unmarshalInt32()
  self.lucky_bag_score_cfgid = os:unmarshalInt32()
  self.client_score = os:unmarshalInt32()
  self.num = os:unmarshalInt32()
end
function SExchangeScoreFailed:sizepolicy(size)
  return size <= 65535
end
return SExchangeScoreFailed
