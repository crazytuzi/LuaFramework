local RoleInfo = require("netio.protocol.mzm.gsp.masswedding.RoleInfo")
local SRandomLuckyBlesserRes = class("SRandomLuckyBlesserRes")
SRandomLuckyBlesserRes.TYPEID = 12604952
function SRandomLuckyBlesserRes:ctor(roleInfo)
  self.id = 12604952
  self.roleInfo = roleInfo or RoleInfo.new()
end
function SRandomLuckyBlesserRes:marshal(os)
  self.roleInfo:marshal(os)
end
function SRandomLuckyBlesserRes:unmarshal(os)
  self.roleInfo = RoleInfo.new()
  self.roleInfo:unmarshal(os)
end
function SRandomLuckyBlesserRes:sizepolicy(size)
  return size <= 65535
end
return SRandomLuckyBlesserRes
