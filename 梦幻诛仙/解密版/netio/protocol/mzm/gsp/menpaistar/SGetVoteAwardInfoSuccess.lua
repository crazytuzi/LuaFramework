local VoteAwardInfo = require("netio.protocol.mzm.gsp.menpaistar.VoteAwardInfo")
local SGetVoteAwardInfoSuccess = class("SGetVoteAwardInfoSuccess")
SGetVoteAwardInfoSuccess.TYPEID = 12612375
function SGetVoteAwardInfoSuccess:ctor(vote_award_info)
  self.id = 12612375
  self.vote_award_info = vote_award_info or VoteAwardInfo.new()
end
function SGetVoteAwardInfoSuccess:marshal(os)
  self.vote_award_info:marshal(os)
end
function SGetVoteAwardInfoSuccess:unmarshal(os)
  self.vote_award_info = VoteAwardInfo.new()
  self.vote_award_info:unmarshal(os)
end
function SGetVoteAwardInfoSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetVoteAwardInfoSuccess
