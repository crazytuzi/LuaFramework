local SGetQuestionVoiceSuccessRes = class("SGetQuestionVoiceSuccessRes")
SGetQuestionVoiceSuccessRes.TYPEID = 12620804
function SGetQuestionVoiceSuccessRes:ctor(activity_id, question_id, answer_list)
  self.id = 12620804
  self.activity_id = activity_id or nil
  self.question_id = question_id or nil
  self.answer_list = answer_list or {}
end
function SGetQuestionVoiceSuccessRes:marshal(os)
  os:marshalInt32(self.activity_id)
  os:marshalInt32(self.question_id)
  os:marshalCompactUInt32(table.getn(self.answer_list))
  for _, v in ipairs(self.answer_list) do
    os:marshalString(v)
  end
end
function SGetQuestionVoiceSuccessRes:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
  self.question_id = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.answer_list, v)
  end
end
function SGetQuestionVoiceSuccessRes:sizepolicy(size)
  return size <= 65535
end
return SGetQuestionVoiceSuccessRes
