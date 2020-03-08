local PictureQuestionInfo = require("netio.protocol.mzm.gsp.question.PictureQuestionInfo")
local SSyncPictureQuestionInfo = class("SSyncPictureQuestionInfo")
SSyncPictureQuestionInfo.TYPEID = 12594733
function SSyncPictureQuestionInfo:ctor(answerRoleId, remainHelperCount, difficultyLevelId, rightCount, totalCount, info, endTime, answerList)
  self.id = 12594733
  self.answerRoleId = answerRoleId or nil
  self.remainHelperCount = remainHelperCount or nil
  self.difficultyLevelId = difficultyLevelId or nil
  self.rightCount = rightCount or nil
  self.totalCount = totalCount or nil
  self.info = info or PictureQuestionInfo.new()
  self.endTime = endTime or nil
  self.answerList = answerList or {}
end
function SSyncPictureQuestionInfo:marshal(os)
  os:marshalInt64(self.answerRoleId)
  os:marshalInt32(self.remainHelperCount)
  os:marshalInt32(self.difficultyLevelId)
  os:marshalInt32(self.rightCount)
  os:marshalInt32(self.totalCount)
  self.info:marshal(os)
  os:marshalInt32(self.endTime)
  os:marshalCompactUInt32(table.getn(self.answerList))
  for _, v in ipairs(self.answerList) do
    v:marshal(os)
  end
end
function SSyncPictureQuestionInfo:unmarshal(os)
  self.answerRoleId = os:unmarshalInt64()
  self.remainHelperCount = os:unmarshalInt32()
  self.difficultyLevelId = os:unmarshalInt32()
  self.rightCount = os:unmarshalInt32()
  self.totalCount = os:unmarshalInt32()
  self.info = PictureQuestionInfo.new()
  self.info:unmarshal(os)
  self.endTime = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.question.AnswerInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.answerList, v)
  end
end
function SSyncPictureQuestionInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncPictureQuestionInfo
