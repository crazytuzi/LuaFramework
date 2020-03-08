local SSyncWordQuestionInfo = class("SSyncWordQuestionInfo")
SSyncWordQuestionInfo.TYPEID = 12594740
function SSyncWordQuestionInfo:ctor(levelCfgId, rightNum, wrongNum, curQuestionId, endTime, sessionid, answer_sequence)
  self.id = 12594740
  self.levelCfgId = levelCfgId or nil
  self.rightNum = rightNum or nil
  self.wrongNum = wrongNum or nil
  self.curQuestionId = curQuestionId or nil
  self.endTime = endTime or nil
  self.sessionid = sessionid or nil
  self.answer_sequence = answer_sequence or {}
end
function SSyncWordQuestionInfo:marshal(os)
  os:marshalInt32(self.levelCfgId)
  os:marshalInt32(self.rightNum)
  os:marshalInt32(self.wrongNum)
  os:marshalInt32(self.curQuestionId)
  os:marshalInt32(self.endTime)
  os:marshalInt64(self.sessionid)
  os:marshalCompactUInt32(table.getn(self.answer_sequence))
  for _, v in ipairs(self.answer_sequence) do
    os:marshalInt32(v)
  end
end
function SSyncWordQuestionInfo:unmarshal(os)
  self.levelCfgId = os:unmarshalInt32()
  self.rightNum = os:unmarshalInt32()
  self.wrongNum = os:unmarshalInt32()
  self.curQuestionId = os:unmarshalInt32()
  self.endTime = os:unmarshalInt32()
  self.sessionid = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.answer_sequence, v)
  end
end
function SSyncWordQuestionInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncWordQuestionInfo
