local CAnswerPictureQuestionReq = class("CAnswerPictureQuestionReq")
CAnswerPictureQuestionReq.TYPEID = 12594729
function CAnswerPictureQuestionReq:ctor(answer)
  self.id = 12594729
  self.answer = answer or nil
end
function CAnswerPictureQuestionReq:marshal(os)
  os:marshalInt32(self.answer)
end
function CAnswerPictureQuestionReq:unmarshal(os)
  self.answer = os:unmarshalInt32()
end
function CAnswerPictureQuestionReq:sizepolicy(size)
  return size <= 65535
end
return CAnswerPictureQuestionReq
