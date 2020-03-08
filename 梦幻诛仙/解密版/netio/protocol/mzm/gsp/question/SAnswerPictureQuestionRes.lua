local PictureQuestionInfo = require("netio.protocol.mzm.gsp.question.PictureQuestionInfo")
local SAnswerPictureQuestionRes = class("SAnswerPictureQuestionRes")
SAnswerPictureQuestionRes.TYPEID = 12594728
function SAnswerPictureQuestionRes:ctor(questionItemId, isRight, nextAnswerRoleId, rightNum, totalNum, lastAnswer, nextQuestionInfo)
  self.id = 12594728
  self.questionItemId = questionItemId or nil
  self.isRight = isRight or nil
  self.nextAnswerRoleId = nextAnswerRoleId or nil
  self.rightNum = rightNum or nil
  self.totalNum = totalNum or nil
  self.lastAnswer = lastAnswer or nil
  self.nextQuestionInfo = nextQuestionInfo or PictureQuestionInfo.new()
end
function SAnswerPictureQuestionRes:marshal(os)
  os:marshalInt32(self.questionItemId)
  os:marshalInt32(self.isRight)
  os:marshalInt64(self.nextAnswerRoleId)
  os:marshalInt32(self.rightNum)
  os:marshalInt32(self.totalNum)
  os:marshalInt32(self.lastAnswer)
  self.nextQuestionInfo:marshal(os)
end
function SAnswerPictureQuestionRes:unmarshal(os)
  self.questionItemId = os:unmarshalInt32()
  self.isRight = os:unmarshalInt32()
  self.nextAnswerRoleId = os:unmarshalInt64()
  self.rightNum = os:unmarshalInt32()
  self.totalNum = os:unmarshalInt32()
  self.lastAnswer = os:unmarshalInt32()
  self.nextQuestionInfo = PictureQuestionInfo.new()
  self.nextQuestionInfo:unmarshal(os)
end
function SAnswerPictureQuestionRes:sizepolicy(size)
  return size <= 65535
end
return SAnswerPictureQuestionRes
