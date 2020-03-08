local OctetsStream = require("netio.OctetsStream")
local FactionMakeUpInfo = class("FactionMakeUpInfo")
function FactionMakeUpInfo:ctor(activityId, curTurn, startTime, questionId, optionIds)
  self.activityId = activityId or nil
  self.curTurn = curTurn or nil
  self.startTime = startTime or nil
  self.questionId = questionId or nil
  self.optionIds = optionIds or {}
end
function FactionMakeUpInfo:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.curTurn)
  os:marshalInt64(self.startTime)
  os:marshalInt32(self.questionId)
  os:marshalCompactUInt32(table.getn(self.optionIds))
  for _, v in ipairs(self.optionIds) do
    os:marshalInt32(v)
  end
end
function FactionMakeUpInfo:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.curTurn = os:unmarshalInt32()
  self.startTime = os:unmarshalInt64()
  self.questionId = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.optionIds, v)
  end
end
return FactionMakeUpInfo
