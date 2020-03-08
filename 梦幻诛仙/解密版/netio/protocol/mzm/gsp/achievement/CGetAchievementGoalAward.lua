local CGetAchievementGoalAward = class("CGetAchievementGoalAward")
CGetAchievementGoalAward.TYPEID = 12603905
function CGetAchievementGoalAward:ctor(activity_cfg_id, goal_cfg_id)
  self.id = 12603905
  self.activity_cfg_id = activity_cfg_id or nil
  self.goal_cfg_id = goal_cfg_id or nil
end
function CGetAchievementGoalAward:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.goal_cfg_id)
end
function CGetAchievementGoalAward:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.goal_cfg_id = os:unmarshalInt32()
end
function CGetAchievementGoalAward:sizepolicy(size)
  return size <= 65535
end
return CGetAchievementGoalAward
