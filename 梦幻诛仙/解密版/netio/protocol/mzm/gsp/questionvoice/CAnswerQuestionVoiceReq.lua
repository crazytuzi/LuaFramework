local CAnswerQuestionVoiceReq = class("CAnswerQuestionVoiceReq")
CAnswerQuestionVoiceReq.TYPEID = 12620802
function CAnswerQuestionVoiceReq:ctor(activity_id, npc_id, question_id, answer_index, session_id)
  self.id = 12620802
  self.activity_id = activity_id or nil
  self.npc_id = npc_id or nil
  self.question_id = question_id or nil
  self.answer_index = answer_index or nil
  self.session_id = session_id or nil
end
function CAnswerQuestionVoiceReq:marshal(os)
  os:marshalInt32(self.activity_id)
  os:marshalInt32(self.npc_id)
  os:marshalInt32(self.question_id)
  os:marshalInt32(self.answer_index)
  os:marshalInt64(self.session_id)
end
function CAnswerQuestionVoiceReq:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
  self.npc_id = os:unmarshalInt32()
  self.question_id = os:unmarshalInt32()
  self.answer_index = os:unmarshalInt32()
  self.session_id = os:unmarshalInt64()
end
function CAnswerQuestionVoiceReq:sizepolicy(size)
  return size <= 65535
end
return CAnswerQuestionVoiceReq
