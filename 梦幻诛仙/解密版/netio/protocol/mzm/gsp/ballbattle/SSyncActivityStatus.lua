local ActivityStatus = require("netio.protocol.mzm.gsp.ballbattle.ActivityStatus")
local SSyncActivityStatus = class("SSyncActivityStatus")
SSyncActivityStatus.TYPEID = 12629265
function SSyncActivityStatus:ctor(status)
  self.id = 12629265
  self.status = status or ActivityStatus.new()
end
function SSyncActivityStatus:marshal(os)
  self.status:marshal(os)
end
function SSyncActivityStatus:unmarshal(os)
  self.status = ActivityStatus.new()
  self.status:unmarshal(os)
end
function SSyncActivityStatus:sizepolicy(size)
  return size <= 65535
end
return SSyncActivityStatus
