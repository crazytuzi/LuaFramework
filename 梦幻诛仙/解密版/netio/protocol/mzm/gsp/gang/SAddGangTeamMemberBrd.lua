local GangTeamMember = require("netio.protocol.mzm.gsp.gang.GangTeamMember")
local SAddGangTeamMemberBrd = class("SAddGangTeamMemberBrd")
SAddGangTeamMemberBrd.TYPEID = 12589992
function SAddGangTeamMemberBrd:ctor(teamid, new_member)
  self.id = 12589992
  self.teamid = teamid or nil
  self.new_member = new_member or GangTeamMember.new()
end
function SAddGangTeamMemberBrd:marshal(os)
  os:marshalInt64(self.teamid)
  self.new_member:marshal(os)
end
function SAddGangTeamMemberBrd:unmarshal(os)
  self.teamid = os:unmarshalInt64()
  self.new_member = GangTeamMember.new()
  self.new_member:unmarshal(os)
end
function SAddGangTeamMemberBrd:sizepolicy(size)
  return size <= 65535
end
return SAddGangTeamMemberBrd
