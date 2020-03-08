local CEnterCompetitionMapReq = class("CEnterCompetitionMapReq")
CEnterCompetitionMapReq.TYPEID = 12598541
function CEnterCompetitionMapReq:ctor(npc)
  self.id = 12598541
  self.npc = npc or nil
end
function CEnterCompetitionMapReq:marshal(os)
  os:marshalInt32(self.npc)
end
function CEnterCompetitionMapReq:unmarshal(os)
  self.npc = os:unmarshalInt32()
end
function CEnterCompetitionMapReq:sizepolicy(size)
  return size <= 65535
end
return CEnterCompetitionMapReq
