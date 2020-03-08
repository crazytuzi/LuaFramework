local TeamInfo = require("netio.protocol.mzm.gsp.instance.TeamInfo")
local SSynLeaderInstanceInfo = class("SSynLeaderInstanceInfo")
SSynLeaderInstanceInfo.TYPEID = 12591382
function SSynLeaderInstanceInfo:ctor(teamInfo)
  self.id = 12591382
  self.teamInfo = teamInfo or TeamInfo.new()
end
function SSynLeaderInstanceInfo:marshal(os)
  self.teamInfo:marshal(os)
end
function SSynLeaderInstanceInfo:unmarshal(os)
  self.teamInfo = TeamInfo.new()
  self.teamInfo:unmarshal(os)
end
function SSynLeaderInstanceInfo:sizepolicy(size)
  return size <= 65535
end
return SSynLeaderInstanceInfo
