local CAnswerDrawAndGuessQuestionReq = class("CAnswerDrawAndGuessQuestionReq")
CAnswerDrawAndGuessQuestionReq.TYPEID = 12617234
function CAnswerDrawAndGuessQuestionReq:ctor(sessionId, answer)
  self.id = 12617234
  self.sessionId = sessionId or nil
  self.answer = answer or nil
end
function CAnswerDrawAndGuessQuestionReq:marshal(os)
  os:marshalInt64(self.sessionId)
  os:marshalString(self.answer)
end
function CAnswerDrawAndGuessQuestionReq:unmarshal(os)
  self.sessionId = os:unmarshalInt64()
  self.answer = os:unmarshalString()
end
function CAnswerDrawAndGuessQuestionReq:sizepolicy(size)
  return size <= 65535
end
return CAnswerDrawAndGuessQuestionReq
