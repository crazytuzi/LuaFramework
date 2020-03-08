local SExchangeScoreSuccess = class("SExchangeScoreSuccess")
SExchangeScoreSuccess.TYPEID = 12607495
function SExchangeScoreSuccess:ctor(score, lucky_bag_score_cfgid, num)
  self.id = 12607495
  self.score = score or nil
  self.lucky_bag_score_cfgid = lucky_bag_score_cfgid or nil
  self.num = num or nil
end
function SExchangeScoreSuccess:marshal(os)
  os:marshalInt32(self.score)
  os:marshalInt32(self.lucky_bag_score_cfgid)
  os:marshalInt32(self.num)
end
function SExchangeScoreSuccess:unmarshal(os)
  self.score = os:unmarshalInt32()
  self.lucky_bag_score_cfgid = os:unmarshalInt32()
  self.num = os:unmarshalInt32()
end
function SExchangeScoreSuccess:sizepolicy(size)
  return size <= 65535
end
return SExchangeScoreSuccess
