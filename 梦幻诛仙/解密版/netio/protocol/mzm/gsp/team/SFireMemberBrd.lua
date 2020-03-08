local SFireMemberBrd = class("SFireMemberBrd")
SFireMemberBrd.TYPEID = 12588314
function SFireMemberBrd:ctor(member)
  self.id = 12588314
  self.member = member or nil
end
function SFireMemberBrd:marshal(os)
  os:marshalInt64(self.member)
end
function SFireMemberBrd:unmarshal(os)
  self.member = os:unmarshalInt64()
end
function SFireMemberBrd:sizepolicy(size)
  return size <= 65535
end
return SFireMemberBrd
