local OctetsStream = require("netio.OctetsStream")
local GetCrossBattleBetRank_ClientReq = class("GetCrossBattleBetRank_ClientReq")
function GetCrossBattleBetRank_ClientReq:ctor(roleid)
  self.roleid = roleid or nil
end
function GetCrossBattleBetRank_ClientReq:marshal(os)
  os:marshalInt64(self.roleid)
end
function GetCrossBattleBetRank_ClientReq:unmarshal(os)
  self.roleid = os:unmarshalInt64()
end
return GetCrossBattleBetRank_ClientReq
