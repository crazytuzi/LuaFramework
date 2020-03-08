local CCheckTeamMemberNumReq = class("CCheckTeamMemberNumReq")
CCheckTeamMemberNumReq.TYPEID = 12588309
function CCheckTeamMemberNumReq:ctor(roleBeCheckedId)
  self.id = 12588309
  self.roleBeCheckedId = roleBeCheckedId or nil
end
function CCheckTeamMemberNumReq:marshal(os)
  os:marshalInt64(self.roleBeCheckedId)
end
function CCheckTeamMemberNumReq:unmarshal(os)
  self.roleBeCheckedId = os:unmarshalInt64()
end
function CCheckTeamMemberNumReq:sizepolicy(size)
  return size <= 65535
end
return CCheckTeamMemberNumReq
