local SGetQuestionVoiceFailRes = class("SGetQuestionVoiceFailRes")
SGetQuestionVoiceFailRes.TYPEID = 12620805
SGetQuestionVoiceFailRes.ERROR_SYSTEM = -1
SGetQuestionVoiceFailRes.ERROR_USERID = -2
SGetQuestionVoiceFailRes.ERROR_CFG = -3
SGetQuestionVoiceFailRes.ERROR_PARAM = -4
SGetQuestionVoiceFailRes.ERROR_NPC_SERVICE = -5
SGetQuestionVoiceFailRes.ERROR_ACTIVITY_CLOSED = -6
SGetQuestionVoiceFailRes.ERROR_NO_QUESTION_COUNT = -7
function SGetQuestionVoiceFailRes:ctor(error_code, params)
  self.id = 12620805
  self.error_code = error_code or nil
  self.params = params or {}
end
function SGetQuestionVoiceFailRes:marshal(os)
  os:marshalInt32(self.error_code)
  os:marshalCompactUInt32(table.getn(self.params))
  for _, v in ipairs(self.params) do
    os:marshalString(v)
  end
end
function SGetQuestionVoiceFailRes:unmarshal(os)
  self.error_code = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.params, v)
  end
end
function SGetQuestionVoiceFailRes:sizepolicy(size)
  return size <= 65535
end
return SGetQuestionVoiceFailRes
