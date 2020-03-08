local CExchangeScore = class("CExchangeScore")
CExchangeScore.TYPEID = 12603402
function CExchangeScore:ctor(exchange_score_cfg_id, current_score_num, exchange_times)
  self.id = 12603402
  self.exchange_score_cfg_id = exchange_score_cfg_id or nil
  self.current_score_num = current_score_num or nil
  self.exchange_times = exchange_times or nil
end
function CExchangeScore:marshal(os)
  os:marshalInt32(self.exchange_score_cfg_id)
  os:marshalInt32(self.current_score_num)
  os:marshalInt32(self.exchange_times)
end
function CExchangeScore:unmarshal(os)
  self.exchange_score_cfg_id = os:unmarshalInt32()
  self.current_score_num = os:unmarshalInt32()
  self.exchange_times = os:unmarshalInt32()
end
function CExchangeScore:sizepolicy(size)
  return size <= 65535
end
return CExchangeScore
