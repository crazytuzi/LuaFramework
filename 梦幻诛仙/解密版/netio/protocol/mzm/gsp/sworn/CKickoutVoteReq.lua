local CKickoutVoteReq = class("CKickoutVoteReq")
CKickoutVoteReq.TYPEID = 12597792
CKickoutVoteReq.VOTE_AGREE = 1
CKickoutVoteReq.VOTE_NOTAGREE = 2
function CKickoutVoteReq:ctor(votevalue)
  self.id = 12597792
  self.votevalue = votevalue or nil
end
function CKickoutVoteReq:marshal(os)
  os:marshalInt32(self.votevalue)
end
function CKickoutVoteReq:unmarshal(os)
  self.votevalue = os:unmarshalInt32()
end
function CKickoutVoteReq:sizepolicy(size)
  return size <= 65535
end
return CKickoutVoteReq
