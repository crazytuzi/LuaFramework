local SSyncDianShiQuestionRes = class("SSyncDianShiQuestionRes")
SSyncDianShiQuestionRes.TYPEID = 12594706
function SSyncDianShiQuestionRes:ctor(questionId, alreadyAnswer, rightAnswer, totalAddTime, sessionid, answer_sequence)
  self.id = 12594706
  self.questionId = questionId or nil
  self.alreadyAnswer = alreadyAnswer or nil
  self.rightAnswer = rightAnswer or nil
  self.totalAddTime = totalAddTime or nil
  self.sessionid = sessionid or nil
  self.answer_sequence = answer_sequence or {}
end
function SSyncDianShiQuestionRes:marshal(os)
  os:marshalInt32(self.questionId)
  os:marshalInt32(self.alreadyAnswer)
  os:marshalInt32(self.rightAnswer)
  os:marshalInt32(self.totalAddTime)
  os:marshalInt64(self.sessionid)
  os:marshalCompactUInt32(table.getn(self.answer_sequence))
  for _, v in ipairs(self.answer_sequence) do
    os:marshalInt32(v)
  end
end
function SSyncDianShiQuestionRes:unmarshal(os)
  self.questionId = os:unmarshalInt32()
  self.alreadyAnswer = os:unmarshalInt32()
  self.rightAnswer = os:unmarshalInt32()
  self.totalAddTime = os:unmarshalInt32()
  self.sessionid = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.answer_sequence, v)
  end
end
function SSyncDianShiQuestionRes:sizepolicy(size)
  return size <= 65535
end
return SSyncDianShiQuestionRes
