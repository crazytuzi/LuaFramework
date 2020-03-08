local CGetAchievementScoreAward = class("CGetAchievementScoreAward")
CGetAchievementScoreAward.TYPEID = 12603906
function CGetAchievementScoreAward:ctor(activity_cfg_id, score)
  self.id = 12603906
  self.activity_cfg_id = activity_cfg_id or nil
  self.score = score or nil
end
function CGetAchievementScoreAward:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.score)
end
function CGetAchievementScoreAward:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.score = os:unmarshalInt32()
end
function CGetAchievementScoreAward:sizepolicy(size)
  return size <= 65535
end
return CGetAchievementScoreAward
