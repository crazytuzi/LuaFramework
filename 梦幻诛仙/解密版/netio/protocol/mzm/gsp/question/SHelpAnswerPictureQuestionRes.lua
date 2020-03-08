local SHelpAnswerPictureQuestionRes = class("SHelpAnswerPictureQuestionRes")
SHelpAnswerPictureQuestionRes.TYPEID = 12594736
function SHelpAnswerPictureQuestionRes:ctor(remainHelperCount)
  self.id = 12594736
  self.remainHelperCount = remainHelperCount or nil
end
function SHelpAnswerPictureQuestionRes:marshal(os)
  os:marshalInt32(self.remainHelperCount)
end
function SHelpAnswerPictureQuestionRes:unmarshal(os)
  self.remainHelperCount = os:unmarshalInt32()
end
function SHelpAnswerPictureQuestionRes:sizepolicy(size)
  return size <= 65535
end
return SHelpAnswerPictureQuestionRes
