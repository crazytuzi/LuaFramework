local SPictureQuestionError = class("SPictureQuestionError")
SPictureQuestionError.TYPEID = 12594743
SPictureQuestionError.ALREADY_IN_PICTURE_QUESTION = 1
SPictureQuestionError.NOT_LEADER = 2
function SPictureQuestionError:ctor(rescode)
  self.id = 12594743
  self.rescode = rescode or nil
end
function SPictureQuestionError:marshal(os)
  os:marshalInt32(self.rescode)
end
function SPictureQuestionError:unmarshal(os)
  self.rescode = os:unmarshalInt32()
end
function SPictureQuestionError:sizepolicy(size)
  return size <= 65535
end
return SPictureQuestionError
