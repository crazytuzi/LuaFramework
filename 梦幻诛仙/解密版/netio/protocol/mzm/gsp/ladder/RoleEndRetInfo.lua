local OctetsStream = require("netio.OctetsStream")
local RoleEndRetInfo = class("RoleEndRetInfo")
function RoleEndRetInfo:ctor(roleid, fightScore)
  self.roleid = roleid or nil
  self.fightScore = fightScore or nil
end
function RoleEndRetInfo:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalInt32(self.fightScore)
end
function RoleEndRetInfo:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.fightScore = os:unmarshalInt32()
end
return RoleEndRetInfo
