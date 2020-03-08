local SGetAchievementScoreAwardSuccess = class("SGetAchievementScoreAwardSuccess")
SGetAchievementScoreAwardSuccess.TYPEID = 12603909
function SGetAchievementScoreAwardSuccess:ctor(activity_cfg_id, score)
  self.id = 12603909
  self.activity_cfg_id = activity_cfg_id or nil
  self.score = score or nil
end
function SGetAchievementScoreAwardSuccess:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.score)
end
function SGetAchievementScoreAwardSuccess:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.score = os:unmarshalInt32()
end
function SGetAchievementScoreAwardSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetAchievementScoreAwardSuccess
