local SGetLastQuestionVoiceFailRes = class("SGetLastQuestionVoiceFailRes")
SGetLastQuestionVoiceFailRes.TYPEID = 12620807
SGetLastQuestionVoiceFailRes.ERROR_SYSTEM = -1
SGetLastQuestionVoiceFailRes.ERROR_USERID = -2
SGetLastQuestionVoiceFailRes.ERROR_CFG = -3
SGetLastQuestionVoiceFailRes.ERROR_PARAM = -4
SGetLastQuestionVoiceFailRes.ERROR_NPC_SERVICE = -5
SGetLastQuestionVoiceFailRes.ERROR_ACTIVITY_CLOSED = -6
SGetLastQuestionVoiceFailRes.ERROR_NO_LAST_QUESTION = -7
function SGetLastQuestionVoiceFailRes:ctor(error_code, params)
  self.id = 12620807
  self.error_code = error_code or nil
  self.params = params or {}
end
function SGetLastQuestionVoiceFailRes:marshal(os)
  os:marshalInt32(self.error_code)
  os:marshalCompactUInt32(table.getn(self.params))
  for _, v in ipairs(self.params) do
    os:marshalString(v)
  end
end
function SGetLastQuestionVoiceFailRes:unmarshal(os)
  self.error_code = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.params, v)
  end
end
function SGetLastQuestionVoiceFailRes:sizepolicy(size)
  return size <= 65535
end
return SGetLastQuestionVoiceFailRes
