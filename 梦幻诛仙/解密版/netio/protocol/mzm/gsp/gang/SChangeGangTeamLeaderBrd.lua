local SChangeGangTeamLeaderBrd = class("SChangeGangTeamLeaderBrd")
SChangeGangTeamLeaderBrd.TYPEID = 12590007
function SChangeGangTeamLeaderBrd:ctor(new_leader, gang_teamid)
  self.id = 12590007
  self.new_leader = new_leader or nil
  self.gang_teamid = gang_teamid or nil
end
function SChangeGangTeamLeaderBrd:marshal(os)
  os:marshalInt64(self.new_leader)
  os:marshalInt64(self.gang_teamid)
end
function SChangeGangTeamLeaderBrd:unmarshal(os)
  self.new_leader = os:unmarshalInt64()
  self.gang_teamid = os:unmarshalInt64()
end
function SChangeGangTeamLeaderBrd:sizepolicy(size)
  return size <= 65535
end
return SChangeGangTeamLeaderBrd
