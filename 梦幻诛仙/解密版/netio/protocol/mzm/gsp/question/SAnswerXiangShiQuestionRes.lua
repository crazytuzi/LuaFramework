local SAnswerXiangShiQuestionRes = class("SAnswerXiangShiQuestionRes")
SAnswerXiangShiQuestionRes.TYPEID = 12594712
function SAnswerXiangShiQuestionRes:ctor(newQuestionId, alreadyAnswer, rightAnswer, sessionid, answer_sequence)
  self.id = 12594712
  self.newQuestionId = newQuestionId or nil
  self.alreadyAnswer = alreadyAnswer or nil
  self.rightAnswer = rightAnswer or nil
  self.sessionid = sessionid or nil
  self.answer_sequence = answer_sequence or {}
end
function SAnswerXiangShiQuestionRes:marshal(os)
  os:marshalInt32(self.newQuestionId)
  os:marshalInt32(self.alreadyAnswer)
  os:marshalInt32(self.rightAnswer)
  os:marshalInt64(self.sessionid)
  os:marshalCompactUInt32(table.getn(self.answer_sequence))
  for _, v in ipairs(self.answer_sequence) do
    os:marshalInt32(v)
  end
end
function SAnswerXiangShiQuestionRes:unmarshal(os)
  self.newQuestionId = os:unmarshalInt32()
  self.alreadyAnswer = os:unmarshalInt32()
  self.rightAnswer = os:unmarshalInt32()
  self.sessionid = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.answer_sequence, v)
  end
end
function SAnswerXiangShiQuestionRes:sizepolicy(size)
  return size <= 65535
end
return SAnswerXiangShiQuestionRes
