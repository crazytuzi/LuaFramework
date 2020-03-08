local CFireCorpsMemberReq = class("CFireCorpsMemberReq")
CFireCorpsMemberReq.TYPEID = 12617476
function CFireCorpsMemberReq:ctor(memberId)
  self.id = 12617476
  self.memberId = memberId or nil
end
function CFireCorpsMemberReq:marshal(os)
  os:marshalInt64(self.memberId)
end
function CFireCorpsMemberReq:unmarshal(os)
  self.memberId = os:unmarshalInt64()
end
function CFireCorpsMemberReq:sizepolicy(size)
  return size <= 65535
end
return CFireCorpsMemberReq
