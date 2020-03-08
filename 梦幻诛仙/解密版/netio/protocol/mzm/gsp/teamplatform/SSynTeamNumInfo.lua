local TeamInfo = require("netio.protocol.mzm.gsp.teamplatform.TeamInfo")
local SSynTeamNumInfo = class("SSynTeamNumInfo")
SSynTeamNumInfo.TYPEID = 12593679
function SSynTeamNumInfo:ctor(newTemInfo)
  self.id = 12593679
  self.newTemInfo = newTemInfo or TeamInfo.new()
end
function SSynTeamNumInfo:marshal(os)
  self.newTemInfo:marshal(os)
end
function SSynTeamNumInfo:unmarshal(os)
  self.newTemInfo = TeamInfo.new()
  self.newTemInfo:unmarshal(os)
end
function SSynTeamNumInfo:sizepolicy(size)
  return size <= 65535
end
return SSynTeamNumInfo
