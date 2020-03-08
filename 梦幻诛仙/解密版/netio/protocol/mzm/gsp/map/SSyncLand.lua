local Location = require("netio.protocol.mzm.gsp.map.Location")
local SSyncLand = class("SSyncLand")
SSyncLand.TYPEID = 12590910
function SSyncLand:ctor(roleid, pos)
  self.id = 12590910
  self.roleid = roleid or nil
  self.pos = pos or Location.new()
end
function SSyncLand:marshal(os)
  os:marshalInt64(self.roleid)
  self.pos:marshal(os)
end
function SSyncLand:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.pos = Location.new()
  self.pos:unmarshal(os)
end
function SSyncLand:sizepolicy(size)
  return size <= 65535
end
return SSyncLand
