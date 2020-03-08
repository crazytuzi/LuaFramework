local SFireCorpsMemberBro = class("SFireCorpsMemberBro")
SFireCorpsMemberBro.TYPEID = 12617482
function SFireCorpsMemberBro:ctor(memberId)
  self.id = 12617482
  self.memberId = memberId or nil
end
function SFireCorpsMemberBro:marshal(os)
  os:marshalInt64(self.memberId)
end
function SFireCorpsMemberBro:unmarshal(os)
  self.memberId = os:unmarshalInt64()
end
function SFireCorpsMemberBro:sizepolicy(size)
  return size <= 65535
end
return SFireCorpsMemberBro
