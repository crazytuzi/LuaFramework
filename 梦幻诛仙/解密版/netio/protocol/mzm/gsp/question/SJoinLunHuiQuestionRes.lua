local SJoinLunHuiQuestionRes = class("SJoinLunHuiQuestionRes")
SJoinLunHuiQuestionRes.TYPEID = 12594691
function SJoinLunHuiQuestionRes:ctor(answeredNum, questionId, money, exp, nextPageIndex, useHelpNum, sessionid, answer_sequence)
  self.id = 12594691
  self.answeredNum = answeredNum or nil
  self.questionId = questionId or nil
  self.money = money or nil
  self.exp = exp or nil
  self.nextPageIndex = nextPageIndex or nil
  self.useHelpNum = useHelpNum or nil
  self.sessionid = sessionid or nil
  self.answer_sequence = answer_sequence or {}
end
function SJoinLunHuiQuestionRes:marshal(os)
  os:marshalInt32(self.answeredNum)
  os:marshalInt32(self.questionId)
  os:marshalInt64(self.money)
  os:marshalInt64(self.exp)
  os:marshalInt32(self.nextPageIndex)
  os:marshalInt32(self.useHelpNum)
  os:marshalInt64(self.sessionid)
  os:marshalCompactUInt32(table.getn(self.answer_sequence))
  for _, v in ipairs(self.answer_sequence) do
    os:marshalInt32(v)
  end
end
function SJoinLunHuiQuestionRes:unmarshal(os)
  self.answeredNum = os:unmarshalInt32()
  self.questionId = os:unmarshalInt32()
  self.money = os:unmarshalInt64()
  self.exp = os:unmarshalInt64()
  self.nextPageIndex = os:unmarshalInt32()
  self.useHelpNum = os:unmarshalInt32()
  self.sessionid = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.answer_sequence, v)
  end
end
function SJoinLunHuiQuestionRes:sizepolicy(size)
  return size <= 65535
end
return SJoinLunHuiQuestionRes
