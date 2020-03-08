local SExchangeScoreSuccess = class("SExchangeScoreSuccess")
SExchangeScoreSuccess.TYPEID = 12603401
function SExchangeScoreSuccess:ctor(current_score_num)
  self.id = 12603401
  self.current_score_num = current_score_num or nil
end
function SExchangeScoreSuccess:marshal(os)
  os:marshalInt32(self.current_score_num)
end
function SExchangeScoreSuccess:unmarshal(os)
  self.current_score_num = os:unmarshalInt32()
end
function SExchangeScoreSuccess:sizepolicy(size)
  return size <= 65535
end
return SExchangeScoreSuccess
