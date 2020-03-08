local SGetLastQuestionVoiceSuccessRes = class("SGetLastQuestionVoiceSuccessRes")
SGetLastQuestionVoiceSuccessRes.TYPEID = 12620808
function SGetLastQuestionVoiceSuccessRes:ctor(activity_id, question_id, answer)
  self.id = 12620808
  self.activity_id = activity_id or nil
  self.question_id = question_id or nil
  self.answer = answer or nil
end
function SGetLastQuestionVoiceSuccessRes:marshal(os)
  os:marshalInt32(self.activity_id)
  os:marshalInt32(self.question_id)
  os:marshalString(self.answer)
end
function SGetLastQuestionVoiceSuccessRes:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
  self.question_id = os:unmarshalInt32()
  self.answer = os:unmarshalString()
end
function SGetLastQuestionVoiceSuccessRes:sizepolicy(size)
  return size <= 65535
end
return SGetLastQuestionVoiceSuccessRes
