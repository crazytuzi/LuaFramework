local AwardBean = require("netio.protocol.mzm.gsp.award.AwardBean")
local SAttendMoneyTreeSuccess = class("SAttendMoneyTreeSuccess")
SAttendMoneyTreeSuccess.TYPEID = 12611330
function SAttendMoneyTreeSuccess:ctor(awardInfo)
  self.id = 12611330
  self.awardInfo = awardInfo or AwardBean.new()
end
function SAttendMoneyTreeSuccess:marshal(os)
  self.awardInfo:marshal(os)
end
function SAttendMoneyTreeSuccess:unmarshal(os)
  self.awardInfo = AwardBean.new()
  self.awardInfo:unmarshal(os)
end
function SAttendMoneyTreeSuccess:sizepolicy(size)
  return size <= 65535
end
return SAttendMoneyTreeSuccess
