local CExchangeScore = class("CExchangeScore")
CExchangeScore.TYPEID = 12607496
function CExchangeScore:ctor(lucky_bag_score_cfgid, client_score, num)
  self.id = 12607496
  self.lucky_bag_score_cfgid = lucky_bag_score_cfgid or nil
  self.client_score = client_score or nil
  self.num = num or nil
end
function CExchangeScore:marshal(os)
  os:marshalInt32(self.lucky_bag_score_cfgid)
  os:marshalInt32(self.client_score)
  os:marshalInt32(self.num)
end
function CExchangeScore:unmarshal(os)
  self.lucky_bag_score_cfgid = os:unmarshalInt32()
  self.client_score = os:unmarshalInt32()
  self.num = os:unmarshalInt32()
end
function CExchangeScore:sizepolicy(size)
  return size <= 65535
end
return CExchangeScore
