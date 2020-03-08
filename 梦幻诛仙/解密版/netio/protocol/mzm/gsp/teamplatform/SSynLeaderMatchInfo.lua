local MatchCfg = require("netio.protocol.mzm.gsp.teamplatform.MatchCfg")
local LevelCfg = require("netio.protocol.mzm.gsp.teamplatform.LevelCfg")
local SSynLeaderMatchInfo = class("SSynLeaderMatchInfo")
SSynLeaderMatchInfo.TYPEID = 12593678
SSynLeaderMatchInfo.SYN__JOIN_TEAM = 1
SSynLeaderMatchInfo.SYN__BEGIN_MATCH = 2
SSynLeaderMatchInfo.SYN__TEAMER_LOGIN = 3
function SSynLeaderMatchInfo:ctor(activityInfo, levelRange, synType)
  self.id = 12593678
  self.activityInfo = activityInfo or MatchCfg.new()
  self.levelRange = levelRange or LevelCfg.new()
  self.synType = synType or nil
end
function SSynLeaderMatchInfo:marshal(os)
  self.activityInfo:marshal(os)
  self.levelRange:marshal(os)
  os:marshalInt32(self.synType)
end
function SSynLeaderMatchInfo:unmarshal(os)
  self.activityInfo = MatchCfg.new()
  self.activityInfo:unmarshal(os)
  self.levelRange = LevelCfg.new()
  self.levelRange:unmarshal(os)
  self.synType = os:unmarshalInt32()
end
function SSynLeaderMatchInfo:sizepolicy(size)
  return size <= 65535
end
return SSynLeaderMatchInfo
