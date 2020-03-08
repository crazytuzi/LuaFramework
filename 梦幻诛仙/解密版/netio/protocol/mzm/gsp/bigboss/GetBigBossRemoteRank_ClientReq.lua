local OctetsStream = require("netio.OctetsStream")
local GetBigBossRemoteRank_ClientReq = class("GetBigBossRemoteRank_ClientReq")
function GetBigBossRemoteRank_ClientReq:ctor(roleid)
  self.roleid = roleid or nil
end
function GetBigBossRemoteRank_ClientReq:marshal(os)
  os:marshalInt64(self.roleid)
end
function GetBigBossRemoteRank_ClientReq:unmarshal(os)
  self.roleid = os:unmarshalInt64()
end
return GetBigBossRemoteRank_ClientReq
