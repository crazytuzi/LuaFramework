local AwardBean = require("netio.protocol.mzm.gsp.award.AwardBean")
local SSendDefaultAwardInfo = class("SSendDefaultAwardInfo")
SSendDefaultAwardInfo.TYPEID = 12583427
function SSendDefaultAwardInfo:ctor(awardInfo)
  self.id = 12583427
  self.awardInfo = awardInfo or AwardBean.new()
end
function SSendDefaultAwardInfo:marshal(os)
  self.awardInfo:marshal(os)
end
function SSendDefaultAwardInfo:unmarshal(os)
  self.awardInfo = AwardBean.new()
  self.awardInfo:unmarshal(os)
end
function SSendDefaultAwardInfo:sizepolicy(size)
  return size <= 65535
end
return SSendDefaultAwardInfo
