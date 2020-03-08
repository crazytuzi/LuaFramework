local CAddNewMemberVoteReq = class("CAddNewMemberVoteReq")
CAddNewMemberVoteReq.TYPEID = 12597795
CAddNewMemberVoteReq.VOTE_AGREE = 1
CAddNewMemberVoteReq.VOTE_NOTAGREE = 2
function CAddNewMemberVoteReq:ctor(votevalue)
  self.id = 12597795
  self.votevalue = votevalue or nil
end
function CAddNewMemberVoteReq:marshal(os)
  os:marshalInt32(self.votevalue)
end
function CAddNewMemberVoteReq:unmarshal(os)
  self.votevalue = os:unmarshalInt32()
end
function CAddNewMemberVoteReq:sizepolicy(size)
  return size <= 65535
end
return CAddNewMemberVoteReq
