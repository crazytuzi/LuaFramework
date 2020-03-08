local SAnswerQuestionVoiceSuccessRes = class("SAnswerQuestionVoiceSuccessRes")
SAnswerQuestionVoiceSuccessRes.TYPEID = 12620806
function SAnswerQuestionVoiceSuccessRes:ctor(activity_id, question_id, answer_result, right_index)
  self.id = 12620806
  self.activity_id = activity_id or nil
  self.question_id = question_id or nil
  self.answer_result = answer_result or nil
  self.right_index = right_index or nil
end
function SAnswerQuestionVoiceSuccessRes:marshal(os)
  os:marshalInt32(self.activity_id)
  os:marshalInt32(self.question_id)
  os:marshalInt32(self.answer_result)
  os:marshalInt32(self.right_index)
end
function SAnswerQuestionVoiceSuccessRes:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
  self.question_id = os:unmarshalInt32()
  self.answer_result = os:unmarshalInt32()
  self.right_index = os:unmarshalInt32()
end
function SAnswerQuestionVoiceSuccessRes:sizepolicy(size)
  return size <= 65535
end
return SAnswerQuestionVoiceSuccessRes
