local AwardBean = require("netio.protocol.mzm.gsp.award.AwardBean")
local SReadStoryAwardRes = class("SReadStoryAwardRes")
SReadStoryAwardRes.TYPEID = 12606470
function SReadStoryAwardRes:ctor(targetAwardBean)
  self.id = 12606470
  self.targetAwardBean = targetAwardBean or AwardBean.new()
end
function SReadStoryAwardRes:marshal(os)
  self.targetAwardBean:marshal(os)
end
function SReadStoryAwardRes:unmarshal(os)
  self.targetAwardBean = AwardBean.new()
  self.targetAwardBean:unmarshal(os)
end
function SReadStoryAwardRes:sizepolicy(size)
  return size <= 65535
end
return SReadStoryAwardRes
