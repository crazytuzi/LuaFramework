local CCreateGangTeamReq = class("CCreateGangTeamReq")
CCreateGangTeamReq.TYPEID = 12589989
function CCreateGangTeamReq:ctor(name)
  self.id = 12589989
  self.name = name or nil
end
function CCreateGangTeamReq:marshal(os)
  os:marshalString(self.name)
end
function CCreateGangTeamReq:unmarshal(os)
  self.name = os:unmarshalString()
end
function CCreateGangTeamReq:sizepolicy(size)
  return size <= 65535
end
return CCreateGangTeamReq
