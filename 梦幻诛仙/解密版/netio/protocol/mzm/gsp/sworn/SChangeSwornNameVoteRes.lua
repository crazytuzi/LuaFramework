local SChangeSwornNameVoteRes = class("SChangeSwornNameVoteRes")
SChangeSwornNameVoteRes.TYPEID = 12597816
SChangeSwornNameVoteRes.SUCCESS = 0
SChangeSwornNameVoteRes.ERROR_UNKNOWN = 1
SChangeSwornNameVoteRes.ERROR_OVERLAP_VOTE = 2
SChangeSwornNameVoteRes.ERROR_VOTE_NOT_EXIST = 3
function SChangeSwornNameVoteRes:ctor(resultcode)
  self.id = 12597816
  self.resultcode = resultcode or nil
end
function SChangeSwornNameVoteRes:marshal(os)
  os:marshalInt32(self.resultcode)
end
function SChangeSwornNameVoteRes:unmarshal(os)
  self.resultcode = os:unmarshalInt32()
end
function SChangeSwornNameVoteRes:sizepolicy(size)
  return size <= 65535
end
return SChangeSwornNameVoteRes
