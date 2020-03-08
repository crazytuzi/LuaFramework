local SCheckTeamMemberNum = class("SCheckTeamMemberNum")
SCheckTeamMemberNum.TYPEID = 12588312
function SCheckTeamMemberNum:ctor(roleBeCheckedId, team, teamMemberNum)
  self.id = 12588312
  self.roleBeCheckedId = roleBeCheckedId or nil
  self.team = team or nil
  self.teamMemberNum = teamMemberNum or nil
end
function SCheckTeamMemberNum:marshal(os)
  os:marshalInt64(self.roleBeCheckedId)
  os:marshalInt64(self.team)
  os:marshalInt32(self.teamMemberNum)
end
function SCheckTeamMemberNum:unmarshal(os)
  self.roleBeCheckedId = os:unmarshalInt64()
  self.team = os:unmarshalInt64()
  self.teamMemberNum = os:unmarshalInt32()
end
function SCheckTeamMemberNum:sizepolicy(size)
  return size <= 65535
end
return SCheckTeamMemberNum
