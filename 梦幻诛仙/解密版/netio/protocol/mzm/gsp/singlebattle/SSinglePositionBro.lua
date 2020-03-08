local RolePosition = require("netio.protocol.mzm.gsp.singlebattle.RolePosition")
local SSinglePositionBro = class("SSinglePositionBro")
SSinglePositionBro.TYPEID = 12621604
function SSinglePositionBro:ctor(roleId, position)
  self.id = 12621604
  self.roleId = roleId or nil
  self.position = position or RolePosition.new()
end
function SSinglePositionBro:marshal(os)
  os:marshalInt64(self.roleId)
  self.position:marshal(os)
end
function SSinglePositionBro:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.position = RolePosition.new()
  self.position:unmarshal(os)
end
function SSinglePositionBro:sizepolicy(size)
  return size <= 65535
end
return SSinglePositionBro
