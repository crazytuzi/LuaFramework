local SXinYouLingXiQuestionInfo = class("SXinYouLingXiQuestionInfo")
SXinYouLingXiQuestionInfo.TYPEID = 12602370
function SXinYouLingXiQuestionInfo:ctor(questionCfgId, sessionId)
  self.id = 12602370
  self.questionCfgId = questionCfgId or nil
  self.sessionId = sessionId or nil
end
function SXinYouLingXiQuestionInfo:marshal(os)
  os:marshalInt32(self.questionCfgId)
  os:marshalInt64(self.sessionId)
end
function SXinYouLingXiQuestionInfo:unmarshal(os)
  self.questionCfgId = os:unmarshalInt32()
  self.sessionId = os:unmarshalInt64()
end
function SXinYouLingXiQuestionInfo:sizepolicy(size)
  return size <= 65535
end
return SXinYouLingXiQuestionInfo
