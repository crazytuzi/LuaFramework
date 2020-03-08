local AwardBean = require("netio.protocol.mzm.gsp.award.AwardBean")
local SScoChallengeAward = class("SScoChallengeAward")
SScoChallengeAward.TYPEID = 12587537
function SScoChallengeAward:ctor(circle, awardBean)
  self.id = 12587537
  self.circle = circle or nil
  self.awardBean = awardBean or AwardBean.new()
end
function SScoChallengeAward:marshal(os)
  os:marshalInt32(self.circle)
  self.awardBean:marshal(os)
end
function SScoChallengeAward:unmarshal(os)
  self.circle = os:unmarshalInt32()
  self.awardBean = AwardBean.new()
  self.awardBean:unmarshal(os)
end
function SScoChallengeAward:sizepolicy(size)
  return size <= 65535
end
return SScoChallengeAward
