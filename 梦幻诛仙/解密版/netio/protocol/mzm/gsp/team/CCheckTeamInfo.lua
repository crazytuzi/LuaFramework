local CCheckTeamInfo = class("CCheckTeamInfo")
CCheckTeamInfo.TYPEID = 12588327
function CCheckTeamInfo:ctor(inviter)
  self.id = 12588327
  self.inviter = inviter or nil
end
function CCheckTeamInfo:marshal(os)
  os:marshalInt64(self.inviter)
end
function CCheckTeamInfo:unmarshal(os)
  self.inviter = os:unmarshalInt64()
end
function CCheckTeamInfo:sizepolicy(size)
  return size <= 65535
end
return CCheckTeamInfo
