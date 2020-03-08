local CFireMemberReq = class("CFireMemberReq")
CFireMemberReq.TYPEID = 12588289
function CFireMemberReq:ctor(member)
  self.id = 12588289
  self.member = member or nil
end
function CFireMemberReq:marshal(os)
  os:marshalInt64(self.member)
end
function CFireMemberReq:unmarshal(os)
  self.member = os:unmarshalInt64()
end
function CFireMemberReq:sizepolicy(size)
  return size <= 65535
end
return CFireMemberReq
