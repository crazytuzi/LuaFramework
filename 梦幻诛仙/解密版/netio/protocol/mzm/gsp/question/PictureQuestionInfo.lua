local OctetsStream = require("netio.OctetsStream")
local PictureQuestionInfo = class("PictureQuestionInfo")
PictureQuestionInfo.RESOURCE_TYPE = 0
function PictureQuestionInfo:ctor(questionItemId, paramMap, answerList)
  self.questionItemId = questionItemId or nil
  self.paramMap = paramMap or {}
  self.answerList = answerList or {}
end
function PictureQuestionInfo:marshal(os)
  os:marshalInt32(self.questionItemId)
  do
    local _size_ = 0
    for _, _ in pairs(self.paramMap) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.paramMap) do
      os:marshalInt32(k)
      os:marshalString(v)
    end
  end
  os:marshalCompactUInt32(table.getn(self.answerList))
  for _, v in ipairs(self.answerList) do
    os:marshalInt32(v)
  end
end
function PictureQuestionInfo:unmarshal(os)
  self.questionItemId = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalString()
    self.paramMap[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.answerList, v)
  end
end
return PictureQuestionInfo
