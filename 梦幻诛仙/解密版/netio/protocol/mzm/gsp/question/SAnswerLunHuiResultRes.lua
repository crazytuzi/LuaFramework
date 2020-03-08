local SAnswerLunHuiResultRes = class("SAnswerLunHuiResultRes")
SAnswerLunHuiResultRes.TYPEID = 12594689
function SAnswerLunHuiResultRes:ctor(nextQuestionId, nextpageIndex, isLastAnswerRight, money, exp, sessionid, answer_sequence)
  self.id = 12594689
  self.nextQuestionId = nextQuestionId or nil
  self.nextpageIndex = nextpageIndex or nil
  self.isLastAnswerRight = isLastAnswerRight or nil
  self.money = money or nil
  self.exp = exp or nil
  self.sessionid = sessionid or nil
  self.answer_sequence = answer_sequence or {}
end
function SAnswerLunHuiResultRes:marshal(os)
  os:marshalInt32(self.nextQuestionId)
  os:marshalInt32(self.nextpageIndex)
  os:marshalInt32(self.isLastAnswerRight)
  os:marshalInt64(self.money)
  os:marshalInt64(self.exp)
  os:marshalInt64(self.sessionid)
  os:marshalCompactUInt32(table.getn(self.answer_sequence))
  for _, v in ipairs(self.answer_sequence) do
    os:marshalInt32(v)
  end
end
function SAnswerLunHuiResultRes:unmarshal(os)
  self.nextQuestionId = os:unmarshalInt32()
  self.nextpageIndex = os:unmarshalInt32()
  self.isLastAnswerRight = os:unmarshalInt32()
  self.money = os:unmarshalInt64()
  self.exp = os:unmarshalInt64()
  self.sessionid = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.answer_sequence, v)
  end
end
function SAnswerLunHuiResultRes:sizepolicy(size)
  return size <= 65535
end
return SAnswerLunHuiResultRes
