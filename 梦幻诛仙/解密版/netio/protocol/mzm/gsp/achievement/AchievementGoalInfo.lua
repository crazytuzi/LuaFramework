local OctetsStream = require("netio.OctetsStream")
local AchievementGoalInfo = class("AchievementGoalInfo")
AchievementGoalInfo.ST_ON_GOING = 1
AchievementGoalInfo.ST_FINISHED = 2
AchievementGoalInfo.ST_HAND_UP = 3
function AchievementGoalInfo:ctor(state, parameters, achieve_time)
  self.state = state or nil
  self.parameters = parameters or {}
  self.achieve_time = achieve_time or nil
end
function AchievementGoalInfo:marshal(os)
  os:marshalInt32(self.state)
  os:marshalCompactUInt32(table.getn(self.parameters))
  for _, v in ipairs(self.parameters) do
    os:marshalInt32(v)
  end
  os:marshalInt64(self.achieve_time)
end
function AchievementGoalInfo:unmarshal(os)
  self.state = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.parameters, v)
  end
  self.achieve_time = os:unmarshalInt64()
end
return AchievementGoalInfo
