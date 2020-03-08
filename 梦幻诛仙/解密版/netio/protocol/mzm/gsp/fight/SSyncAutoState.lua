local AutoFightInfo = require("netio.protocol.mzm.gsp.fight.AutoFightInfo")
local SSyncAutoState = class("SSyncAutoState")
SSyncAutoState.TYPEID = 12594183
function SSyncAutoState:ctor(info)
  self.id = 12594183
  self.info = info or AutoFightInfo.new()
end
function SSyncAutoState:marshal(os)
  self.info:marshal(os)
end
function SSyncAutoState:unmarshal(os)
  self.info = AutoFightInfo.new()
  self.info:unmarshal(os)
end
function SSyncAutoState:sizepolicy(size)
  return size <= 65535
end
return SSyncAutoState
