local CAnswerDianShiShiQuestionReq = class("CAnswerDianShiShiQuestionReq")
CAnswerDianShiShiQuestionReq.TYPEID = 12594704
function CAnswerDianShiShiQuestionReq:ctor(questionid, answerIdx, sessionid)
  self.id = 12594704
  self.questionid = questionid or nil
  self.answerIdx = answerIdx or nil
  self.sessionid = sessionid or nil
end
function CAnswerDianShiShiQuestionReq:marshal(os)
  os:marshalInt32(self.questionid)
  os:marshalInt32(self.answerIdx)
  os:marshalInt64(self.sessionid)
end
function CAnswerDianShiShiQuestionReq:unmarshal(os)
  self.questionid = os:unmarshalInt32()
  self.answerIdx = os:unmarshalInt32()
  self.sessionid = os:unmarshalInt64()
end
function CAnswerDianShiShiQuestionReq:sizepolicy(size)
  return size <= 65535
end
return CAnswerDianShiShiQuestionReq
