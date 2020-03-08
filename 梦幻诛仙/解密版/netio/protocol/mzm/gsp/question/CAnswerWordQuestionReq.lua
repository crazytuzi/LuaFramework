local CAnswerWordQuestionReq = class("CAnswerWordQuestionReq")
CAnswerWordQuestionReq.TYPEID = 12594739
function CAnswerWordQuestionReq:ctor(answerIdx, curQuestionId, sessionid)
  self.id = 12594739
  self.answerIdx = answerIdx or nil
  self.curQuestionId = curQuestionId or nil
  self.sessionid = sessionid or nil
end
function CAnswerWordQuestionReq:marshal(os)
  os:marshalInt32(self.answerIdx)
  os:marshalInt32(self.curQuestionId)
  os:marshalInt64(self.sessionid)
end
function CAnswerWordQuestionReq:unmarshal(os)
  self.answerIdx = os:unmarshalInt32()
  self.curQuestionId = os:unmarshalInt32()
  self.sessionid = os:unmarshalInt64()
end
function CAnswerWordQuestionReq:sizepolicy(size)
  return size <= 65535
end
return CAnswerWordQuestionReq
