local SGetHuiShiQuestionRes = class("SGetHuiShiQuestionRes")
SGetHuiShiQuestionRes.TYPEID = 12594705
function SGetHuiShiQuestionRes:ctor(questionId, alreadyAnswer, rightAnswer, totalAddTime, startTime, sessionid, answer_sequence)
  self.id = 12594705
  self.questionId = questionId or nil
  self.alreadyAnswer = alreadyAnswer or nil
  self.rightAnswer = rightAnswer or nil
  self.totalAddTime = totalAddTime or nil
  self.startTime = startTime or nil
  self.sessionid = sessionid or nil
  self.answer_sequence = answer_sequence or {}
end
function SGetHuiShiQuestionRes:marshal(os)
  os:marshalInt32(self.questionId)
  os:marshalInt32(self.alreadyAnswer)
  os:marshalInt32(self.rightAnswer)
  os:marshalInt32(self.totalAddTime)
  os:marshalInt32(self.startTime)
  os:marshalInt64(self.sessionid)
  os:marshalCompactUInt32(table.getn(self.answer_sequence))
  for _, v in ipairs(self.answer_sequence) do
    os:marshalInt32(v)
  end
end
function SGetHuiShiQuestionRes:unmarshal(os)
  self.questionId = os:unmarshalInt32()
  self.alreadyAnswer = os:unmarshalInt32()
  self.rightAnswer = os:unmarshalInt32()
  self.totalAddTime = os:unmarshalInt32()
  self.startTime = os:unmarshalInt32()
  self.sessionid = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.answer_sequence, v)
  end
end
function SGetHuiShiQuestionRes:sizepolicy(size)
  return size <= 65535
end
return SGetHuiShiQuestionRes
