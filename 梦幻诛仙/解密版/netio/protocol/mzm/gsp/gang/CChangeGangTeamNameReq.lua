local CChangeGangTeamNameReq = class("CChangeGangTeamNameReq")
CChangeGangTeamNameReq.TYPEID = 12590002
function CChangeGangTeamNameReq:ctor(name)
  self.id = 12590002
  self.name = name or nil
end
function CChangeGangTeamNameReq:marshal(os)
  os:marshalString(self.name)
end
function CChangeGangTeamNameReq:unmarshal(os)
  self.name = os:unmarshalString()
end
function CChangeGangTeamNameReq:sizepolicy(size)
  return size <= 65535
end
return CChangeGangTeamNameReq
