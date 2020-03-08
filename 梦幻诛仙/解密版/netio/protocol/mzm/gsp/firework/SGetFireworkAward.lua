local AwardBean = require("netio.protocol.mzm.gsp.award.AwardBean")
local SGetFireworkAward = class("SGetFireworkAward")
SGetFireworkAward.TYPEID = 12625153
function SGetFireworkAward:ctor(activityId, awardBean, hitCount)
  self.id = 12625153
  self.activityId = activityId or nil
  self.awardBean = awardBean or AwardBean.new()
  self.hitCount = hitCount or nil
end
function SGetFireworkAward:marshal(os)
  os:marshalInt32(self.activityId)
  self.awardBean:marshal(os)
  os:marshalInt32(self.hitCount)
end
function SGetFireworkAward:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.awardBean = AwardBean.new()
  self.awardBean:unmarshal(os)
  self.hitCount = os:unmarshalInt32()
end
function SGetFireworkAward:sizepolicy(size)
  return size <= 65535
end
return SGetFireworkAward
