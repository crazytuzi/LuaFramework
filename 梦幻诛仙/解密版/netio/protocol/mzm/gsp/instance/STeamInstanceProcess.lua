local TeamInfo = require("netio.protocol.mzm.gsp.instance.TeamInfo")
local STeamInstanceProcess = class("STeamInstanceProcess")
STeamInstanceProcess.TYPEID = 12591363
function STeamInstanceProcess:ctor(teamInstanceInfo)
  self.id = 12591363
  self.teamInstanceInfo = teamInstanceInfo or TeamInfo.new()
end
function STeamInstanceProcess:marshal(os)
  self.teamInstanceInfo:marshal(os)
end
function STeamInstanceProcess:unmarshal(os)
  self.teamInstanceInfo = TeamInfo.new()
  self.teamInstanceInfo:unmarshal(os)
end
function STeamInstanceProcess:sizepolicy(size)
  return size <= 65535
end
return STeamInstanceProcess
