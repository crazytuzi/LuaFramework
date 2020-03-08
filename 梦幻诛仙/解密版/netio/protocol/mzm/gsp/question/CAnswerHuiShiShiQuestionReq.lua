local CAnswerHuiShiShiQuestionReq = class("CAnswerHuiShiShiQuestionReq")
CAnswerHuiShiShiQuestionReq.TYPEID = 12594723
function CAnswerHuiShiShiQuestionReq:ctor(questionid, answerIdx, sessionid)
  self.id = 12594723
  self.questionid = questionid or nil
  self.answerIdx = answerIdx or nil
  self.sessionid = sessionid or nil
end
function CAnswerHuiShiShiQuestionReq:marshal(os)
  os:marshalInt32(self.questionid)
  os:marshalInt32(self.answerIdx)
  os:marshalInt64(self.sessionid)
end
function CAnswerHuiShiShiQuestionReq:unmarshal(os)
  self.questionid = os:unmarshalInt32()
  self.answerIdx = os:unmarshalInt32()
  self.sessionid = os:unmarshalInt64()
end
function CAnswerHuiShiShiQuestionReq:sizepolicy(size)
  return size <= 65535
end
return CAnswerHuiShiShiQuestionReq
