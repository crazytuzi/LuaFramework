local GameStatus = require("netio.protocol.mzm.gsp.ballbattle.GameStatus")
local SSyncGameStatus = class("SSyncGameStatus")
SSyncGameStatus.TYPEID = 12629254
function SSyncGameStatus:ctor(status)
  self.id = 12629254
  self.status = status or GameStatus.new()
end
function SSyncGameStatus:marshal(os)
  self.status:marshal(os)
end
function SSyncGameStatus:unmarshal(os)
  self.status = GameStatus.new()
  self.status:unmarshal(os)
end
function SSyncGameStatus:sizepolicy(size)
  return size <= 65535
end
return SSyncGameStatus
