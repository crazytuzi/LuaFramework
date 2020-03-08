local SQYXTQuestionRes = class("SQYXTQuestionRes")
SQYXTQuestionRes.TYPEID = 12594744
function SQYXTQuestionRes:ctor(questionId, alreadyAnswer, rightAnswer, useGangHelpTimes, isInGangHelp, session_id, answer_sequence)
  self.id = 12594744
  self.questionId = questionId or nil
  self.alreadyAnswer = alreadyAnswer or nil
  self.rightAnswer = rightAnswer or nil
  self.useGangHelpTimes = useGangHelpTimes or nil
  self.isInGangHelp = isInGangHelp or nil
  self.session_id = session_id or nil
  self.answer_sequence = answer_sequence or {}
end
function SQYXTQuestionRes:marshal(os)
  os:marshalInt32(self.questionId)
  os:marshalInt32(self.alreadyAnswer)
  os:marshalInt32(self.rightAnswer)
  os:marshalInt32(self.useGangHelpTimes)
  os:marshalInt32(self.isInGangHelp)
  os:marshalInt64(self.session_id)
  os:marshalCompactUInt32(table.getn(self.answer_sequence))
  for _, v in ipairs(self.answer_sequence) do
    os:marshalInt32(v)
  end
end
function SQYXTQuestionRes:unmarshal(os)
  self.questionId = os:unmarshalInt32()
  self.alreadyAnswer = os:unmarshalInt32()
  self.rightAnswer = os:unmarshalInt32()
  self.useGangHelpTimes = os:unmarshalInt32()
  self.isInGangHelp = os:unmarshalInt32()
  self.session_id = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.answer_sequence, v)
  end
end
function SQYXTQuestionRes:sizepolicy(size)
  return size <= 65535
end
return SQYXTQuestionRes
