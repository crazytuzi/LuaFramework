local SAnswerQuestionVoiceFailRes = class("SAnswerQuestionVoiceFailRes")
SAnswerQuestionVoiceFailRes.TYPEID = 12620803
SAnswerQuestionVoiceFailRes.ERROR_SYSTEM = -1
SAnswerQuestionVoiceFailRes.ERROR_USERID = -2
SAnswerQuestionVoiceFailRes.ERROR_CFG = -3
SAnswerQuestionVoiceFailRes.ERROR_PARAM = -4
SAnswerQuestionVoiceFailRes.ERROR_NPC_SERVICE = -5
SAnswerQuestionVoiceFailRes.ERROR_ACTIVITY_CLOSED = -6
SAnswerQuestionVoiceFailRes.ERROR_TIME_OUT = -7
SAnswerQuestionVoiceFailRes.ERROR_NO_QUESTION_COUNT = -8
SAnswerQuestionVoiceFailRes.ERROR_NO_QUESTION_NOW = -9
function SAnswerQuestionVoiceFailRes:ctor(error_code, params)
  self.id = 12620803
  self.error_code = error_code or nil
  self.params = params or {}
end
function SAnswerQuestionVoiceFailRes:marshal(os)
  os:marshalInt32(self.error_code)
  os:marshalCompactUInt32(table.getn(self.params))
  for _, v in ipairs(self.params) do
    os:marshalString(v)
  end
end
function SAnswerQuestionVoiceFailRes:unmarshal(os)
  self.error_code = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.params, v)
  end
end
function SAnswerQuestionVoiceFailRes:sizepolicy(size)
  return size <= 65535
end
return SAnswerQuestionVoiceFailRes
