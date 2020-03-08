local SAnswerWordQuestionRes = class("SAnswerWordQuestionRes")
SAnswerWordQuestionRes.TYPEID = 12594738
function SAnswerWordQuestionRes:ctor(isRight, nextQuestionId, sessionid, answer_sequence)
  self.id = 12594738
  self.isRight = isRight or nil
  self.nextQuestionId = nextQuestionId or nil
  self.sessionid = sessionid or nil
  self.answer_sequence = answer_sequence or {}
end
function SAnswerWordQuestionRes:marshal(os)
  os:marshalInt32(self.isRight)
  os:marshalInt32(self.nextQuestionId)
  os:marshalInt64(self.sessionid)
  os:marshalCompactUInt32(table.getn(self.answer_sequence))
  for _, v in ipairs(self.answer_sequence) do
    os:marshalInt32(v)
  end
end
function SAnswerWordQuestionRes:unmarshal(os)
  self.isRight = os:unmarshalInt32()
  self.nextQuestionId = os:unmarshalInt32()
  self.sessionid = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.answer_sequence, v)
  end
end
function SAnswerWordQuestionRes:sizepolicy(size)
  return size <= 65535
end
return SAnswerWordQuestionRes
