local OctetsStream = require("netio.OctetsStream")
local GetRoleCrossFieldRank_ClientReq = class("GetRoleCrossFieldRank_ClientReq")
function GetRoleCrossFieldRank_ClientReq:ctor(roleid)
  self.roleid = roleid or nil
end
function GetRoleCrossFieldRank_ClientReq:marshal(os)
  os:marshalInt64(self.roleid)
end
function GetRoleCrossFieldRank_ClientReq:unmarshal(os)
  self.roleid = os:unmarshalInt64()
end
return GetRoleCrossFieldRank_ClientReq
