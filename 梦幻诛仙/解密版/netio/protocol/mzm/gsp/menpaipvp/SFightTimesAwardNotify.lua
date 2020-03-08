local AwardBean = require("netio.protocol.mzm.gsp.award.AwardBean")
local SFightTimesAwardNotify = class("SFightTimesAwardNotify")
SFightTimesAwardNotify.TYPEID = 12596237
function SFightTimesAwardNotify:ctor(award)
  self.id = 12596237
  self.award = award or AwardBean.new()
end
function SFightTimesAwardNotify:marshal(os)
  self.award:marshal(os)
end
function SFightTimesAwardNotify:unmarshal(os)
  self.award = AwardBean.new()
  self.award:unmarshal(os)
end
function SFightTimesAwardNotify:sizepolicy(size)
  return size <= 65535
end
return SFightTimesAwardNotify
