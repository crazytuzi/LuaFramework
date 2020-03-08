local LostExpInfo = require("netio.protocol.mzm.gsp.award.LostExpInfo")
local SSynSingleLostExpInfo = class("SSynSingleLostExpInfo")
SSynSingleLostExpInfo.TYPEID = 12583449
function SSynSingleLostExpInfo:ctor(activityId, lostExpInfo)
  self.id = 12583449
  self.activityId = activityId or nil
  self.lostExpInfo = lostExpInfo or LostExpInfo.new()
end
function SSynSingleLostExpInfo:marshal(os)
  os:marshalInt32(self.activityId)
  self.lostExpInfo:marshal(os)
end
function SSynSingleLostExpInfo:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.lostExpInfo = LostExpInfo.new()
  self.lostExpInfo:unmarshal(os)
end
function SSynSingleLostExpInfo:sizepolicy(size)
  return size <= 65535
end
return SSynSingleLostExpInfo
