local OctetsStream = require("netio.OctetsStream")
local MatchCfg = class("MatchCfg")
function MatchCfg:ctor(matchCfgId, index)
  self.matchCfgId = matchCfgId or nil
  self.index = index or nil
end
function MatchCfg:marshal(os)
  os:marshalInt32(self.matchCfgId)
  os:marshalInt32(self.index)
end
function MatchCfg:unmarshal(os)
  self.matchCfgId = os:unmarshalInt32()
  self.index = os:unmarshalInt32()
end
return MatchCfg
