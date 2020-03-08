local AwardBean = require("netio.protocol.mzm.gsp.award.AwardBean")
local SShimenDayPerfectAward = class("SShimenDayPerfectAward")
SShimenDayPerfectAward.TYPEID = 12587541
function SShimenDayPerfectAward:ctor(awardBean)
  self.id = 12587541
  self.awardBean = awardBean or AwardBean.new()
end
function SShimenDayPerfectAward:marshal(os)
  self.awardBean:marshal(os)
end
function SShimenDayPerfectAward:unmarshal(os)
  self.awardBean = AwardBean.new()
  self.awardBean:unmarshal(os)
end
function SShimenDayPerfectAward:sizepolicy(size)
  return size <= 65535
end
return SShimenDayPerfectAward
