local SAnswerDrawAndGuessQuestionFailRep = class("SAnswerDrawAndGuessQuestionFailRep")
SAnswerDrawAndGuessQuestionFailRep.TYPEID = 12617246
SAnswerDrawAndGuessQuestionFailRep.ERROR_SYSTEM = -1
SAnswerDrawAndGuessQuestionFailRep.ERROR_USERID = -2
SAnswerDrawAndGuessQuestionFailRep.ERROR_CFG = -3
SAnswerDrawAndGuessQuestionFailRep.ERROR_DRAWER_CANNOT_ANSWER = -4
SAnswerDrawAndGuessQuestionFailRep.ERROR_CAN_NOT_JOIN_ACTIVITY = -5
SAnswerDrawAndGuessQuestionFailRep.ERROR_NOT_IN_TEAM = -6
SAnswerDrawAndGuessQuestionFailRep.ERROR_TIME_OUT = -7
SAnswerDrawAndGuessQuestionFailRep.ERROR_ANSWER_ILLEGAL = -8
SAnswerDrawAndGuessQuestionFailRep.ERROR_NOT_IN_GAME = -9
SAnswerDrawAndGuessQuestionFailRep.ERROR_HAS_SENSITIVE_WORDS = -10
SAnswerDrawAndGuessQuestionFailRep.ERROR_ANSWER_TOO_QUICK = -11
function SAnswerDrawAndGuessQuestionFailRep:ctor(error_code, params)
  self.id = 12617246
  self.error_code = error_code or nil
  self.params = params or {}
end
function SAnswerDrawAndGuessQuestionFailRep:marshal(os)
  os:marshalInt32(self.error_code)
  os:marshalCompactUInt32(table.getn(self.params))
  for _, v in ipairs(self.params) do
    os:marshalString(v)
  end
end
function SAnswerDrawAndGuessQuestionFailRep:unmarshal(os)
  self.error_code = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.params, v)
  end
end
function SAnswerDrawAndGuessQuestionFailRep:sizepolicy(size)
  return size <= 65535
end
return SAnswerDrawAndGuessQuestionFailRep
