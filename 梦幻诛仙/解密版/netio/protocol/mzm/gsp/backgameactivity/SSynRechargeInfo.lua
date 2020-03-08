local RechargeInfo = require("netio.protocol.mzm.gsp.backgameactivity.RechargeInfo")
local SSynRechargeInfo = class("SSynRechargeInfo")
SSynRechargeInfo.TYPEID = 12620565
function SSynRechargeInfo:ctor(activityId, rechargeInfo)
  self.id = 12620565
  self.activityId = activityId or nil
  self.rechargeInfo = rechargeInfo or RechargeInfo.new()
end
function SSynRechargeInfo:marshal(os)
  os:marshalInt32(self.activityId)
  self.rechargeInfo:marshal(os)
end
function SSynRechargeInfo:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.rechargeInfo = RechargeInfo.new()
  self.rechargeInfo:unmarshal(os)
end
function SSynRechargeInfo:sizepolicy(size)
  return size <= 65535
end
return SSynRechargeInfo
