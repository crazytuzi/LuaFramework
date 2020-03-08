local RoleInfo = require("netio.protocol.mzm.gsp.masswedding.RoleInfo")
local SNotifyLuckyBlesser = class("SNotifyLuckyBlesser")
SNotifyLuckyBlesser.TYPEID = 12604956
function SNotifyLuckyBlesser:ctor(roleInfo)
  self.id = 12604956
  self.roleInfo = roleInfo or RoleInfo.new()
end
function SNotifyLuckyBlesser:marshal(os)
  self.roleInfo:marshal(os)
end
function SNotifyLuckyBlesser:unmarshal(os)
  self.roleInfo = RoleInfo.new()
  self.roleInfo:unmarshal(os)
end
function SNotifyLuckyBlesser:sizepolicy(size)
  return size <= 65535
end
return SNotifyLuckyBlesser
