local OctetsStream = require("netio.OctetsStream")
local GetLadderRankRange_ClientReq = class("GetLadderRankRange_ClientReq")
function GetLadderRankRange_ClientReq:ctor(roleid)
  self.roleid = roleid or nil
end
function GetLadderRankRange_ClientReq:marshal(os)
  os:marshalInt64(self.roleid)
end
function GetLadderRankRange_ClientReq:unmarshal(os)
  self.roleid = os:unmarshalInt64()
end
return GetLadderRankRange_ClientReq
