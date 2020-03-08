local OctetsStream = require("netio.OctetsStream")
local GetRoleBigBossRemoteRank_ClientReq = class("GetRoleBigBossRemoteRank_ClientReq")
function GetRoleBigBossRemoteRank_ClientReq:ctor(roleid)
  self.roleid = roleid or nil
end
function GetRoleBigBossRemoteRank_ClientReq:marshal(os)
  os:marshalInt64(self.roleid)
end
function GetRoleBigBossRemoteRank_ClientReq:unmarshal(os)
  self.roleid = os:unmarshalInt64()
end
return GetRoleBigBossRemoteRank_ClientReq
