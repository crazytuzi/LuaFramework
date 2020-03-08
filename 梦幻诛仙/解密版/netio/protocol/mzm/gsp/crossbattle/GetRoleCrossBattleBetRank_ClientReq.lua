local OctetsStream = require("netio.OctetsStream")
local GetRoleCrossBattleBetRank_ClientReq = class("GetRoleCrossBattleBetRank_ClientReq")
function GetRoleCrossBattleBetRank_ClientReq:ctor(roleid)
  self.roleid = roleid or nil
end
function GetRoleCrossBattleBetRank_ClientReq:marshal(os)
  os:marshalInt64(self.roleid)
end
function GetRoleCrossBattleBetRank_ClientReq:unmarshal(os)
  self.roleid = os:unmarshalInt64()
end
return GetRoleCrossBattleBetRank_ClientReq
