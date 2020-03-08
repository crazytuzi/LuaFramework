local SMapTeamLeaveView = class("SMapTeamLeaveView")
SMapTeamLeaveView.TYPEID = 12590861
function SMapTeamLeaveView:ctor(teamId)
  self.id = 12590861
  self.teamId = teamId or nil
end
function SMapTeamLeaveView:marshal(os)
  os:marshalInt64(self.teamId)
end
function SMapTeamLeaveView:unmarshal(os)
  self.teamId = os:unmarshalInt64()
end
function SMapTeamLeaveView:sizepolicy(size)
  return size <= 65535
end
return SMapTeamLeaveView
