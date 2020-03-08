local AwardBean = require("netio.protocol.mzm.gsp.award.AwardBean")
local SSyncVisibleMonsterReward = class("SSyncVisibleMonsterReward")
SSyncVisibleMonsterReward.TYPEID = 12587543
SSyncVisibleMonsterReward.ACTIVITY_SHENGXIAO = 0
SSyncVisibleMonsterReward.ACTIVITY_YAOSHOUTUXI = 1
SSyncVisibleMonsterReward.ACTIVITY_GANGROBBER = 2
function SSyncVisibleMonsterReward:ctor(awardBean, activityType)
  self.id = 12587543
  self.awardBean = awardBean or AwardBean.new()
  self.activityType = activityType or nil
end
function SSyncVisibleMonsterReward:marshal(os)
  self.awardBean:marshal(os)
  os:marshalInt32(self.activityType)
end
function SSyncVisibleMonsterReward:unmarshal(os)
  self.awardBean = AwardBean.new()
  self.awardBean:unmarshal(os)
  self.activityType = os:unmarshalInt32()
end
function SSyncVisibleMonsterReward:sizepolicy(size)
  return size <= 65535
end
return SSyncVisibleMonsterReward
