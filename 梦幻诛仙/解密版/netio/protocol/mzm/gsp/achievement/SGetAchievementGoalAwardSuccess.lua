local SGetAchievementGoalAwardSuccess = class("SGetAchievementGoalAwardSuccess")
SGetAchievementGoalAwardSuccess.TYPEID = 12603908
function SGetAchievementGoalAwardSuccess:ctor(activity_cfg_id, goal_cfg_id, now_score_value)
  self.id = 12603908
  self.activity_cfg_id = activity_cfg_id or nil
  self.goal_cfg_id = goal_cfg_id or nil
  self.now_score_value = now_score_value or nil
end
function SGetAchievementGoalAwardSuccess:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.goal_cfg_id)
  os:marshalInt32(self.now_score_value)
end
function SGetAchievementGoalAwardSuccess:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.goal_cfg_id = os:unmarshalInt32()
  self.now_score_value = os:unmarshalInt32()
end
function SGetAchievementGoalAwardSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetAchievementGoalAwardSuccess
