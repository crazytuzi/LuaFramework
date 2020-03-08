local SQuestionContext = class("SQuestionContext")
SQuestionContext.TYPEID = 12587578
function SQuestionContext:ctor(questionId)
  self.id = 12587578
  self.questionId = questionId or nil
end
function SQuestionContext:marshal(os)
  os:marshalInt32(self.questionId)
end
function SQuestionContext:unmarshal(os)
  self.questionId = os:unmarshalInt32()
end
function SQuestionContext:sizepolicy(size)
  return size <= 65535
end
return SQuestionContext
