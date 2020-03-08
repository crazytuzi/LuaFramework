local AchievementGoalInfo = require("netio.protocol.mzm.gsp.achievement.AchievementGoalInfo")
local SSynAchievementGoalInfo = class("SSynAchievementGoalInfo")
SSynAchievementGoalInfo.TYPEID = 12603910
function SSynAchievementGoalInfo:ctor(activity_cfg_id, goal_cfg_id, goal_info, now_score_value)
  self.id = 12603910
  self.activity_cfg_id = activity_cfg_id or nil
  self.goal_cfg_id = goal_cfg_id or nil
  self.goal_info = goal_info or AchievementGoalInfo.new()
  self.now_score_value = now_score_value or nil
end
function SSynAchievementGoalInfo:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.goal_cfg_id)
  self.goal_info:marshal(os)
  os:marshalInt32(self.now_score_value)
end
function SSynAchievementGoalInfo:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.goal_cfg_id = os:unmarshalInt32()
  self.goal_info = AchievementGoalInfo.new()
  self.goal_info:unmarshal(os)
  self.now_score_value = os:unmarshalInt32()
end
function SSynAchievementGoalInfo:sizepolicy(size)
  return size <= 65535
end
return SSynAchievementGoalInfo
