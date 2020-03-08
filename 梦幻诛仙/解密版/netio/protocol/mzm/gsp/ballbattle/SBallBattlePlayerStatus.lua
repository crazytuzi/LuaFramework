local PlayerStatus = require("netio.protocol.mzm.gsp.ballbattle.PlayerStatus")
local SBallBattlePlayerStatus = class("SBallBattlePlayerStatus")
SBallBattlePlayerStatus.TYPEID = 12629260
function SBallBattlePlayerStatus:ctor(status)
  self.id = 12629260
  self.status = status or PlayerStatus.new()
end
function SBallBattlePlayerStatus:marshal(os)
  self.status:marshal(os)
end
function SBallBattlePlayerStatus:unmarshal(os)
  self.status = PlayerStatus.new()
  self.status:unmarshal(os)
end
function SBallBattlePlayerStatus:sizepolicy(size)
  return size <= 65535
end
return SBallBattlePlayerStatus
