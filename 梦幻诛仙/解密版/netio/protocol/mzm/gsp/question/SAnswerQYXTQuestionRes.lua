local SAnswerQYXTQuestionRes = class("SAnswerQYXTQuestionRes")
SAnswerQYXTQuestionRes.TYPEID = 12594745
function SAnswerQYXTQuestionRes:ctor(newQuestionId, rightAnswer, session_id, answer_sequence)
  self.id = 12594745
  self.newQuestionId = newQuestionId or nil
  self.rightAnswer = rightAnswer or nil
  self.session_id = session_id or nil
  self.answer_sequence = answer_sequence or {}
end
function SAnswerQYXTQuestionRes:marshal(os)
  os:marshalInt32(self.newQuestionId)
  os:marshalInt32(self.rightAnswer)
  os:marshalInt64(self.session_id)
  os:marshalCompactUInt32(table.getn(self.answer_sequence))
  for _, v in ipairs(self.answer_sequence) do
    os:marshalInt32(v)
  end
end
function SAnswerQYXTQuestionRes:unmarshal(os)
  self.newQuestionId = os:unmarshalInt32()
  self.rightAnswer = os:unmarshalInt32()
  self.session_id = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.answer_sequence, v)
  end
end
function SAnswerQYXTQuestionRes:sizepolicy(size)
  return size <= 65535
end
return SAnswerQYXTQuestionRes
