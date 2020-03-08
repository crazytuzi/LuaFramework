local AwardBean = require("netio.protocol.mzm.gsp.award.AwardBean")
local SShimenWeekPerfectAward = class("SShimenWeekPerfectAward")
SShimenWeekPerfectAward.TYPEID = 12587540
function SShimenWeekPerfectAward:ctor(awardBean)
  self.id = 12587540
  self.awardBean = awardBean or AwardBean.new()
end
function SShimenWeekPerfectAward:marshal(os)
  self.awardBean:marshal(os)
end
function SShimenWeekPerfectAward:unmarshal(os)
  self.awardBean = AwardBean.new()
  self.awardBean:unmarshal(os)
end
function SShimenWeekPerfectAward:sizepolicy(size)
  return size <= 65535
end
return SShimenWeekPerfectAward
