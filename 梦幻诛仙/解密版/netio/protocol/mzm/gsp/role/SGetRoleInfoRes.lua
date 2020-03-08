local RoleInfo = require("netio.protocol.mzm.gsp.role.RoleInfo")
local SGetRoleInfoRes = class("SGetRoleInfoRes")
SGetRoleInfoRes.TYPEID = 12586004
function SGetRoleInfoRes:ctor(roleInfo)
  self.id = 12586004
  self.roleInfo = roleInfo or RoleInfo.new()
end
function SGetRoleInfoRes:marshal(os)
  self.roleInfo:marshal(os)
end
function SGetRoleInfoRes:unmarshal(os)
  self.roleInfo = RoleInfo.new()
  self.roleInfo:unmarshal(os)
end
function SGetRoleInfoRes:sizepolicy(size)
  return size <= 65535
end
return SGetRoleInfoRes
