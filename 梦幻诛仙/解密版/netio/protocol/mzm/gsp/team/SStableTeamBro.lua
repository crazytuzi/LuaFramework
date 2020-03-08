local SStableTeamBro = class("SStableTeamBro")
SStableTeamBro.TYPEID = 12588340
SStableTeamBro.STABLE_YES = 1
SStableTeamBro.STABLE_NO = 2
function SStableTeamBro:ctor(state)
  self.id = 12588340
  self.state = state or nil
end
function SStableTeamBro:marshal(os)
  os:marshalInt32(self.state)
end
function SStableTeamBro:unmarshal(os)
  self.state = os:unmarshalInt32()
end
function SStableTeamBro:sizepolicy(size)
  return size <= 65535
end
return SStableTeamBro
