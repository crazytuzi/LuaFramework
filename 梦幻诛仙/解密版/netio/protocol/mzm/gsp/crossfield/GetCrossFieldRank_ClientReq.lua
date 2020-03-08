local OctetsStream = require("netio.OctetsStream")
local GetCrossFieldRank_ClientReq = class("GetCrossFieldRank_ClientReq")
function GetCrossFieldRank_ClientReq:ctor(roleid)
  self.roleid = roleid or nil
end
function GetCrossFieldRank_ClientReq:marshal(os)
  os:marshalInt64(self.roleid)
end
function GetCrossFieldRank_ClientReq:unmarshal(os)
  self.roleid = os:unmarshalInt64()
end
return GetCrossFieldRank_ClientReq
