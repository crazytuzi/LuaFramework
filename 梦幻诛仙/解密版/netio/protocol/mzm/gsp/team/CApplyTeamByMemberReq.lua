local CApplyTeamByMemberReq = class("CApplyTeamByMemberReq")
CApplyTeamByMemberReq.TYPEID = 12588298
function CApplyTeamByMemberReq:ctor(member)
  self.id = 12588298
  self.member = member or nil
end
function CApplyTeamByMemberReq:marshal(os)
  os:marshalInt64(self.member)
end
function CApplyTeamByMemberReq:unmarshal(os)
  self.member = os:unmarshalInt64()
end
function CApplyTeamByMemberReq:sizepolicy(size)
  return size <= 65535
end
return CApplyTeamByMemberReq
