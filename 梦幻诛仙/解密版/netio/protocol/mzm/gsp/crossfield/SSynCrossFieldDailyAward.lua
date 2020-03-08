local AwardBean = require("netio.protocol.mzm.gsp.award.AwardBean")
local SSynCrossFieldDailyAward = class("SSynCrossFieldDailyAward")
SSynCrossFieldDailyAward.TYPEID = 12619539
function SSynCrossFieldDailyAward:ctor(award_info)
  self.id = 12619539
  self.award_info = award_info or AwardBean.new()
end
function SSynCrossFieldDailyAward:marshal(os)
  self.award_info:marshal(os)
end
function SSynCrossFieldDailyAward:unmarshal(os)
  self.award_info = AwardBean.new()
  self.award_info:unmarshal(os)
end
function SSynCrossFieldDailyAward:sizepolicy(size)
  return size <= 65535
end
return SSynCrossFieldDailyAward
