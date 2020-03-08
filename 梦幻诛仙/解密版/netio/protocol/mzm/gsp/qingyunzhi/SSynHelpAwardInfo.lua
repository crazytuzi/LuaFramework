local AwardBean = require("netio.protocol.mzm.gsp.award.AwardBean")
local SSynHelpAwardInfo = class("SSynHelpAwardInfo")
SSynHelpAwardInfo.TYPEID = 12590343
function SSynHelpAwardInfo:ctor(outPostType, awardBean, leftHelpCount)
  self.id = 12590343
  self.outPostType = outPostType or nil
  self.awardBean = awardBean or AwardBean.new()
  self.leftHelpCount = leftHelpCount or nil
end
function SSynHelpAwardInfo:marshal(os)
  os:marshalInt32(self.outPostType)
  self.awardBean:marshal(os)
  os:marshalInt32(self.leftHelpCount)
end
function SSynHelpAwardInfo:unmarshal(os)
  self.outPostType = os:unmarshalInt32()
  self.awardBean = AwardBean.new()
  self.awardBean:unmarshal(os)
  self.leftHelpCount = os:unmarshalInt32()
end
function SSynHelpAwardInfo:sizepolicy(size)
  return size <= 65535
end
return SSynHelpAwardInfo
