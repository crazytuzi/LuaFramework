local MatchCfg = require("netio.protocol.mzm.gsp.teamplatform.MatchCfg")
local CCheckMatchMembers = class("CCheckMatchMembers")
CCheckMatchMembers.TYPEID = 12593682
function CCheckMatchMembers:ctor(matchCfg)
  self.id = 12593682
  self.matchCfg = matchCfg or MatchCfg.new()
end
function CCheckMatchMembers:marshal(os)
  self.matchCfg:marshal(os)
end
function CCheckMatchMembers:unmarshal(os)
  self.matchCfg = MatchCfg.new()
  self.matchCfg:unmarshal(os)
end
function CCheckMatchMembers:sizepolicy(size)
  return size <= 65535
end
return CCheckMatchMembers
