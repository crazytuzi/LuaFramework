local SKickoutVoteRes = class("SKickoutVoteRes")
SKickoutVoteRes.TYPEID = 12597815
SKickoutVoteRes.SUCCESS = 0
SKickoutVoteRes.ERROR_UNKNOWN = 1
SKickoutVoteRes.ERROR_OVERLAP_VOTE = 2
SKickoutVoteRes.ERROR_VOTE_NOT_EXIST = 3
SKickoutVoteRes.ERROR_MEMBER_LEAVE = 4
function SKickoutVoteRes:ctor(resultcode)
  self.id = 12597815
  self.resultcode = resultcode or nil
end
function SKickoutVoteRes:marshal(os)
  os:marshalInt32(self.resultcode)
end
function SKickoutVoteRes:unmarshal(os)
  self.resultcode = os:unmarshalInt32()
end
function SKickoutVoteRes:sizepolicy(size)
  return size <= 65535
end
return SKickoutVoteRes
