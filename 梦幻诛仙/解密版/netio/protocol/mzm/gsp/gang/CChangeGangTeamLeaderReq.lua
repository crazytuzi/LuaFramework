local CChangeGangTeamLeaderReq = class("CChangeGangTeamLeaderReq")
CChangeGangTeamLeaderReq.TYPEID = 12590006
function CChangeGangTeamLeaderReq:ctor(new_leader)
  self.id = 12590006
  self.new_leader = new_leader or nil
end
function CChangeGangTeamLeaderReq:marshal(os)
  os:marshalInt64(self.new_leader)
end
function CChangeGangTeamLeaderReq:unmarshal(os)
  self.new_leader = os:unmarshalInt64()
end
function CChangeGangTeamLeaderReq:sizepolicy(size)
  return size <= 65535
end
return CChangeGangTeamLeaderReq
