local CHelpAnswerPictureQuestionReq = class("CHelpAnswerPictureQuestionReq")
CHelpAnswerPictureQuestionReq.TYPEID = 12594732
function CHelpAnswerPictureQuestionReq:ctor(answer, questionId)
  self.id = 12594732
  self.answer = answer or nil
  self.questionId = questionId or nil
end
function CHelpAnswerPictureQuestionReq:marshal(os)
  os:marshalInt32(self.answer)
  os:marshalInt32(self.questionId)
end
function CHelpAnswerPictureQuestionReq:unmarshal(os)
  self.answer = os:unmarshalInt32()
  self.questionId = os:unmarshalInt32()
end
function CHelpAnswerPictureQuestionReq:sizepolicy(size)
  return size <= 65535
end
return CHelpAnswerPictureQuestionReq
