local SAddNewMemberVoteRes = class("SAddNewMemberVoteRes")
SAddNewMemberVoteRes.TYPEID = 12597808
SAddNewMemberVoteRes.SUCCESS = 0
SAddNewMemberVoteRes.ERROR_UNKNOWN = 1
SAddNewMemberVoteRes.ERROR_OVERLAP_VOTE = 2
SAddNewMemberVoteRes.ERROR_VOTE_NOT_EXIST = 3
SAddNewMemberVoteRes.ERROR_NEWMEMBER_SWORN = 4
function SAddNewMemberVoteRes:ctor(resultcode)
  self.id = 12597808
  self.resultcode = resultcode or nil
end
function SAddNewMemberVoteRes:marshal(os)
  os:marshalInt32(self.resultcode)
end
function SAddNewMemberVoteRes:unmarshal(os)
  self.resultcode = os:unmarshalInt32()
end
function SAddNewMemberVoteRes:sizepolicy(size)
  return size <= 65535
end
return SAddNewMemberVoteRes
