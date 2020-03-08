local VoteAwardInfo = require("netio.protocol.mzm.gsp.menpaistar.VoteAwardInfo")
local SSetAwardSuccess = class("SSetAwardSuccess")
SSetAwardSuccess.TYPEID = 12612358
function SSetAwardSuccess:ctor(vote_award_info)
  self.id = 12612358
  self.vote_award_info = vote_award_info or VoteAwardInfo.new()
end
function SSetAwardSuccess:marshal(os)
  self.vote_award_info:marshal(os)
end
function SSetAwardSuccess:unmarshal(os)
  self.vote_award_info = VoteAwardInfo.new()
  self.vote_award_info:unmarshal(os)
end
function SSetAwardSuccess:sizepolicy(size)
  return size <= 65535
end
return SSetAwardSuccess
