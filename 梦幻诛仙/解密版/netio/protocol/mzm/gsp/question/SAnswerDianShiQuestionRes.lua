local SAnswerDianShiQuestionRes = class("SAnswerDianShiQuestionRes")
SAnswerDianShiQuestionRes.TYPEID = 12594717
function SAnswerDianShiQuestionRes:ctor(newQuestionId, alreadyAnswer, rightAnswer, totalAddTime, sessionid, answer_sequence)
  self.id = 12594717
  self.newQuestionId = newQuestionId or nil
  self.alreadyAnswer = alreadyAnswer or nil
  self.rightAnswer = rightAnswer or nil
  self.totalAddTime = totalAddTime or nil
  self.sessionid = sessionid or nil
  self.answer_sequence = answer_sequence or {}
end
function SAnswerDianShiQuestionRes:marshal(os)
  os:marshalInt32(self.newQuestionId)
  os:marshalInt32(self.alreadyAnswer)
  os:marshalInt32(self.rightAnswer)
  os:marshalInt32(self.totalAddTime)
  os:marshalInt64(self.sessionid)
  os:marshalCompactUInt32(table.getn(self.answer_sequence))
  for _, v in ipairs(self.answer_sequence) do
    os:marshalInt32(v)
  end
end
function SAnswerDianShiQuestionRes:unmarshal(os)
  self.newQuestionId = os:unmarshalInt32()
  self.alreadyAnswer = os:unmarshalInt32()
  self.rightAnswer = os:unmarshalInt32()
  self.totalAddTime = os:unmarshalInt32()
  self.sessionid = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.answer_sequence, v)
  end
end
function SAnswerDianShiQuestionRes:sizepolicy(size)
  return size <= 65535
end
return SAnswerDianShiQuestionRes
