local SAnswerXinYouLingXiResult = class("SAnswerXinYouLingXiResult")
SAnswerXinYouLingXiResult.TYPEID = 12602376
function SAnswerXinYouLingXiResult:ctor(isMatch)
  self.id = 12602376
  self.isMatch = isMatch or nil
end
function SAnswerXinYouLingXiResult:marshal(os)
  os:marshalInt32(self.isMatch)
end
function SAnswerXinYouLingXiResult:unmarshal(os)
  self.isMatch = os:unmarshalInt32()
end
function SAnswerXinYouLingXiResult:sizepolicy(size)
  return size <= 65535
end
return SAnswerXinYouLingXiResult
