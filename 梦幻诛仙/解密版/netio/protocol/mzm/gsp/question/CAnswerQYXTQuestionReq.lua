local CAnswerQYXTQuestionReq = class("CAnswerQYXTQuestionReq")
CAnswerQYXTQuestionReq.TYPEID = 12594746
function CAnswerQYXTQuestionReq:ctor(questionid, answerIdx, session_id)
  self.id = 12594746
  self.questionid = questionid or nil
  self.answerIdx = answerIdx or nil
  self.session_id = session_id or nil
end
function CAnswerQYXTQuestionReq:marshal(os)
  os:marshalInt32(self.questionid)
  os:marshalInt32(self.answerIdx)
  os:marshalInt64(self.session_id)
end
function CAnswerQYXTQuestionReq:unmarshal(os)
  self.questionid = os:unmarshalInt32()
  self.answerIdx = os:unmarshalInt32()
  self.session_id = os:unmarshalInt64()
end
function CAnswerQYXTQuestionReq:sizepolicy(size)
  return size <= 65535
end
return CAnswerQYXTQuestionReq
