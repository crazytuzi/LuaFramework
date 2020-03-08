local AwardBean = require("netio.protocol.mzm.gsp.award.AwardBean")
local SSendAwardInfoWithStorageExp = class("SSendAwardInfoWithStorageExp")
SSendAwardInfoWithStorageExp.TYPEID = 12583429
function SSendAwardInfoWithStorageExp:ctor(awardInfo, addExp)
  self.id = 12583429
  self.awardInfo = awardInfo or AwardBean.new()
  self.addExp = addExp or nil
end
function SSendAwardInfoWithStorageExp:marshal(os)
  self.awardInfo:marshal(os)
  os:marshalInt32(self.addExp)
end
function SSendAwardInfoWithStorageExp:unmarshal(os)
  self.awardInfo = AwardBean.new()
  self.awardInfo:unmarshal(os)
  self.addExp = os:unmarshalInt32()
end
function SSendAwardInfoWithStorageExp:sizepolicy(size)
  return size <= 65535
end
return SSendAwardInfoWithStorageExp
