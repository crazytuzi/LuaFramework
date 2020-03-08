local SAnswerDrawAndGuessQuestionSuccessRep = class("SAnswerDrawAndGuessQuestionSuccessRep")
SAnswerDrawAndGuessQuestionSuccessRep.TYPEID = 12617237
function SAnswerDrawAndGuessQuestionSuccessRep:ctor(result)
  self.id = 12617237
  self.result = result or nil
end
function SAnswerDrawAndGuessQuestionSuccessRep:marshal(os)
  os:marshalInt32(self.result)
end
function SAnswerDrawAndGuessQuestionSuccessRep:unmarshal(os)
  self.result = os:unmarshalInt32()
end
function SAnswerDrawAndGuessQuestionSuccessRep:sizepolicy(size)
  return size <= 65535
end
return SAnswerDrawAndGuessQuestionSuccessRep
