local Location = require("netio.protocol.mzm.gsp.map.Location")
local CLand = class("CLand")
CLand.TYPEID = 12590905
function CLand:ctor(pos)
  self.id = 12590905
  self.pos = pos or Location.new()
end
function CLand:marshal(os)
  self.pos:marshal(os)
end
function CLand:unmarshal(os)
  self.pos = Location.new()
  self.pos:unmarshal(os)
end
function CLand:sizepolicy(size)
  return size <= 65535
end
return CLand
