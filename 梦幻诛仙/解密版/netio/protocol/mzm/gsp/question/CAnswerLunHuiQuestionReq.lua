local CAnswerLunHuiQuestionReq = class("CAnswerLunHuiQuestionReq")
CAnswerLunHuiQuestionReq.TYPEID = 12594694
function CAnswerLunHuiQuestionReq:ctor(answerIconId, questionId, pageIndex, sessionid)
  self.id = 12594694
  self.answerIconId = answerIconId or nil
  self.questionId = questionId or nil
  self.pageIndex = pageIndex or nil
  self.sessionid = sessionid or nil
end
function CAnswerLunHuiQuestionReq:marshal(os)
  os:marshalInt32(self.answerIconId)
  os:marshalInt32(self.questionId)
  os:marshalInt32(self.pageIndex)
  os:marshalInt64(self.sessionid)
end
function CAnswerLunHuiQuestionReq:unmarshal(os)
  self.answerIconId = os:unmarshalInt32()
  self.questionId = os:unmarshalInt32()
  self.pageIndex = os:unmarshalInt32()
  self.sessionid = os:unmarshalInt64()
end
function CAnswerLunHuiQuestionReq:sizepolicy(size)
  return size <= 65535
end
return CAnswerLunHuiQuestionReq
