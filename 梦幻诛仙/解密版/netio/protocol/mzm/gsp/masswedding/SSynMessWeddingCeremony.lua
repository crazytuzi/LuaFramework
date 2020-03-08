local CoupleInfo = require("netio.protocol.mzm.gsp.masswedding.CoupleInfo")
local SSynMessWeddingCeremony = class("SSynMessWeddingCeremony")
SSynMessWeddingCeremony.TYPEID = 12604946
function SSynMessWeddingCeremony:ctor(triggerType, coupleInfo)
  self.id = 12604946
  self.triggerType = triggerType or nil
  self.coupleInfo = coupleInfo or CoupleInfo.new()
end
function SSynMessWeddingCeremony:marshal(os)
  os:marshalInt32(self.triggerType)
  self.coupleInfo:marshal(os)
end
function SSynMessWeddingCeremony:unmarshal(os)
  self.triggerType = os:unmarshalInt32()
  self.coupleInfo = CoupleInfo.new()
  self.coupleInfo:unmarshal(os)
end
function SSynMessWeddingCeremony:sizepolicy(size)
  return size <= 65535
end
return SSynMessWeddingCeremony
