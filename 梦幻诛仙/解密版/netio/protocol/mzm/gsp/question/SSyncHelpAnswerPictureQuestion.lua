local SSyncHelpAnswerPictureQuestion = class("SSyncHelpAnswerPictureQuestion")
SSyncHelpAnswerPictureQuestion.TYPEID = 12594735
function SSyncHelpAnswerPictureQuestion:ctor(answerProviderId, questionItemId, answer)
  self.id = 12594735
  self.answerProviderId = answerProviderId or nil
  self.questionItemId = questionItemId or nil
  self.answer = answer or nil
end
function SSyncHelpAnswerPictureQuestion:marshal(os)
  os:marshalInt64(self.answerProviderId)
  os:marshalInt32(self.questionItemId)
  os:marshalInt32(self.answer)
end
function SSyncHelpAnswerPictureQuestion:unmarshal(os)
  self.answerProviderId = os:unmarshalInt64()
  self.questionItemId = os:unmarshalInt32()
  self.answer = os:unmarshalInt32()
end
function SSyncHelpAnswerPictureQuestion:sizepolicy(size)
  return size <= 65535
end
return SSyncHelpAnswerPictureQuestion
