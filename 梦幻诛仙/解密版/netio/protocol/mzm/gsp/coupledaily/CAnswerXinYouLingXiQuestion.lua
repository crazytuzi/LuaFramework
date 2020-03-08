local CAnswerXinYouLingXiQuestion = class("CAnswerXinYouLingXiQuestion")
CAnswerXinYouLingXiQuestion.TYPEID = 12602381
function CAnswerXinYouLingXiQuestion:ctor(answer, sessionId)
  self.id = 12602381
  self.answer = answer or nil
  self.sessionId = sessionId or nil
end
function CAnswerXinYouLingXiQuestion:marshal(os)
  os:marshalInt32(self.answer)
  os:marshalInt64(self.sessionId)
end
function CAnswerXinYouLingXiQuestion:unmarshal(os)
  self.answer = os:unmarshalInt32()
  self.sessionId = os:unmarshalInt64()
end
function CAnswerXinYouLingXiQuestion:sizepolicy(size)
  return size <= 65535
end
return CAnswerXinYouLingXiQuestion
