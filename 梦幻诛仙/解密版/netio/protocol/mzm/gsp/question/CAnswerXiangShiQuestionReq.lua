local CAnswerXiangShiQuestionReq = class("CAnswerXiangShiQuestionReq")
CAnswerXiangShiQuestionReq.TYPEID = 12594714
function CAnswerXiangShiQuestionReq:ctor(questionid, answerIdx, sessionid)
  self.id = 12594714
  self.questionid = questionid or nil
  self.answerIdx = answerIdx or nil
  self.sessionid = sessionid or nil
end
function CAnswerXiangShiQuestionReq:marshal(os)
  os:marshalInt32(self.questionid)
  os:marshalInt32(self.answerIdx)
  os:marshalInt64(self.sessionid)
end
function CAnswerXiangShiQuestionReq:unmarshal(os)
  self.questionid = os:unmarshalInt32()
  self.answerIdx = os:unmarshalInt32()
  self.sessionid = os:unmarshalInt64()
end
function CAnswerXiangShiQuestionReq:sizepolicy(size)
  return size <= 65535
end
return CAnswerXiangShiQuestionReq
