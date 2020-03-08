local VoteAwardInfo = require("netio.protocol.mzm.gsp.menpaistar.VoteAwardInfo")
local SSetAwardFailed = class("SSetAwardFailed")
SSetAwardFailed.TYPEID = 12612371
SSetAwardFailed.ERROR_YUANBAO_NOT_ENOUGH = -1
SSetAwardFailed.ERROR_VOTE_NUM_INCONSISTENT = -2
SSetAwardFailed.ERROR_ACTIVITY_IN_AWARD = -3
function SSetAwardFailed:ctor(client_yuanbao, vote_award_info, vote_num, retcode)
  self.id = 12612371
  self.client_yuanbao = client_yuanbao or nil
  self.vote_award_info = vote_award_info or VoteAwardInfo.new()
  self.vote_num = vote_num or nil
  self.retcode = retcode or nil
end
function SSetAwardFailed:marshal(os)
  os:marshalInt64(self.client_yuanbao)
  self.vote_award_info:marshal(os)
  os:marshalInt32(self.vote_num)
  os:marshalInt32(self.retcode)
end
function SSetAwardFailed:unmarshal(os)
  self.client_yuanbao = os:unmarshalInt64()
  self.vote_award_info = VoteAwardInfo.new()
  self.vote_award_info:unmarshal(os)
  self.vote_num = os:unmarshalInt32()
  self.retcode = os:unmarshalInt32()
end
function SSetAwardFailed:sizepolicy(size)
  return size <= 65535
end
return SSetAwardFailed
