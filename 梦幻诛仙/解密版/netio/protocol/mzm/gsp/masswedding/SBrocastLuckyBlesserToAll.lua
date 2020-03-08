local RoleInfo = require("netio.protocol.mzm.gsp.masswedding.RoleInfo")
local SBrocastLuckyBlesserToAll = class("SBrocastLuckyBlesserToAll")
SBrocastLuckyBlesserToAll.TYPEID = 12604960
function SBrocastLuckyBlesserToAll:ctor(operRoleInfo, luckyRoleInfo)
  self.id = 12604960
  self.operRoleInfo = operRoleInfo or RoleInfo.new()
  self.luckyRoleInfo = luckyRoleInfo or RoleInfo.new()
end
function SBrocastLuckyBlesserToAll:marshal(os)
  self.operRoleInfo:marshal(os)
  self.luckyRoleInfo:marshal(os)
end
function SBrocastLuckyBlesserToAll:unmarshal(os)
  self.operRoleInfo = RoleInfo.new()
  self.operRoleInfo:unmarshal(os)
  self.luckyRoleInfo = RoleInfo.new()
  self.luckyRoleInfo:unmarshal(os)
end
function SBrocastLuckyBlesserToAll:sizepolicy(size)
  return size <= 65535
end
return SBrocastLuckyBlesserToAll
