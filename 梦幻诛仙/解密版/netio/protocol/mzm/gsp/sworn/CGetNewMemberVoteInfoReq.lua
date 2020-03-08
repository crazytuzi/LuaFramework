local CGetNewMemberVoteInfoReq = class("CGetNewMemberVoteInfoReq")
CGetNewMemberVoteInfoReq.TYPEID = 12597809
function CGetNewMemberVoteInfoReq:ctor()
  self.id = 12597809
end
function CGetNewMemberVoteInfoReq:marshal(os)
end
function CGetNewMemberVoteInfoReq:unmarshal(os)
end
function CGetNewMemberVoteInfoReq:sizepolicy(size)
  return size <= 65535
end
return CGetNewMemberVoteInfoReq
