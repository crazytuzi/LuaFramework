local CJoinFightRep = class("CJoinFightRep")
CJoinFightRep.TYPEID = 12592147
function CJoinFightRep:ctor(sessionId, repResult)
  self.id = 12592147
  self.sessionId = sessionId or nil
  self.repResult = repResult or nil
end
function CJoinFightRep:marshal(os)
  os:marshalInt64(self.sessionId)
  os:marshalInt32(self.repResult)
end
function CJoinFightRep:unmarshal(os)
  self.sessionId = os:unmarshalInt64()
  self.repResult = os:unmarshalInt32()
end
function CJoinFightRep:sizepolicy(size)
  return size <= 65535
end
return CJoinFightRep
