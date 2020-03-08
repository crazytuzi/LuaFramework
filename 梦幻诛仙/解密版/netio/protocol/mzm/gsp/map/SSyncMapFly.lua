local Location = require("netio.protocol.mzm.gsp.map.Location")
local SSyncMapFly = class("SSyncMapFly")
SSyncMapFly.TYPEID = 12590886
function SSyncMapFly:ctor(roleId, targetPos)
  self.id = 12590886
  self.roleId = roleId or nil
  self.targetPos = targetPos or Location.new()
end
function SSyncMapFly:marshal(os)
  os:marshalInt64(self.roleId)
  self.targetPos:marshal(os)
end
function SSyncMapFly:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.targetPos = Location.new()
  self.targetPos:unmarshal(os)
end
function SSyncMapFly:sizepolicy(size)
  return size <= 65535
end
return SSyncMapFly
