local AwardBean = require("netio.protocol.mzm.gsp.award.AwardBean")
local SSynQMHWFightAward = class("SSynQMHWFightAward")
SSynQMHWFightAward.TYPEID = 12601863
function SSynQMHWFightAward:ctor(awardBean, score)
  self.id = 12601863
  self.awardBean = awardBean or AwardBean.new()
  self.score = score or nil
end
function SSynQMHWFightAward:marshal(os)
  self.awardBean:marshal(os)
  os:marshalInt32(self.score)
end
function SSynQMHWFightAward:unmarshal(os)
  self.awardBean = AwardBean.new()
  self.awardBean:unmarshal(os)
  self.score = os:unmarshalInt32()
end
function SSynQMHWFightAward:sizepolicy(size)
  return size <= 65535
end
return SSynQMHWFightAward
