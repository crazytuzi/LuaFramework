local OctetsStream = require("netio.OctetsStream")
local GangTeamMember = class("GangTeamMember")
function GangTeamMember:ctor(roleid, join_time)
  self.roleid = roleid or nil
  self.join_time = join_time or nil
end
function GangTeamMember:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalInt64(self.join_time)
end
function GangTeamMember:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.join_time = os:unmarshalInt64()
end
return GangTeamMember
