local OctetsStream = require("netio.OctetsStream")
local GetLadderRoleRank_SelfReq = class("GetLadderRoleRank_SelfReq")
function GetLadderRoleRank_SelfReq:ctor(roleid)
  self.roleid = roleid or nil
end
function GetLadderRoleRank_SelfReq:marshal(os)
  os:marshalInt64(self.roleid)
end
function GetLadderRoleRank_SelfReq:unmarshal(os)
  self.roleid = os:unmarshalInt64()
end
return GetLadderRoleRank_SelfReq
