local SActiveLeaveCorpsBro = class("SActiveLeaveCorpsBro")
SActiveLeaveCorpsBro.TYPEID = 12617484
function SActiveLeaveCorpsBro:ctor(memberId)
  self.id = 12617484
  self.memberId = memberId or nil
end
function SActiveLeaveCorpsBro:marshal(os)
  os:marshalInt64(self.memberId)
end
function SActiveLeaveCorpsBro:unmarshal(os)
  self.memberId = os:unmarshalInt64()
end
function SActiveLeaveCorpsBro:sizepolicy(size)
  return size <= 65535
end
return SActiveLeaveCorpsBro
