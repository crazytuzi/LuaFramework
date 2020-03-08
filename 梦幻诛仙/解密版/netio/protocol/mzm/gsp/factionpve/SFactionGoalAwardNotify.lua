local AwardBean = require("netio.protocol.mzm.gsp.award.AwardBean")
local SFactionGoalAwardNotify = class("SFactionGoalAwardNotify")
SFactionGoalAwardNotify.TYPEID = 12613654
function SFactionGoalAwardNotify:ctor(award)
  self.id = 12613654
  self.award = award or AwardBean.new()
end
function SFactionGoalAwardNotify:marshal(os)
  self.award:marshal(os)
end
function SFactionGoalAwardNotify:unmarshal(os)
  self.award = AwardBean.new()
  self.award:unmarshal(os)
end
function SFactionGoalAwardNotify:sizepolicy(size)
  return size <= 65535
end
return SFactionGoalAwardNotify
