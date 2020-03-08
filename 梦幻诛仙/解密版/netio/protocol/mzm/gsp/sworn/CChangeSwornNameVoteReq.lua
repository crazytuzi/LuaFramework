local CChangeSwornNameVoteReq = class("CChangeSwornNameVoteReq")
CChangeSwornNameVoteReq.TYPEID = 12597797
CChangeSwornNameVoteReq.VOTE_AGREE = 1
CChangeSwornNameVoteReq.VOTE_NOTAGREE = 2
function CChangeSwornNameVoteReq:ctor(votevalue)
  self.id = 12597797
  self.votevalue = votevalue or nil
end
function CChangeSwornNameVoteReq:marshal(os)
  os:marshalInt32(self.votevalue)
end
function CChangeSwornNameVoteReq:unmarshal(os)
  self.votevalue = os:unmarshalInt32()
end
function CChangeSwornNameVoteReq:sizepolicy(size)
  return size <= 65535
end
return CChangeSwornNameVoteReq
