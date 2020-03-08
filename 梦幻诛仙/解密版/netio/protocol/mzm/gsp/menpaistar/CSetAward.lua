local VoteAwardInfo = require("netio.protocol.mzm.gsp.menpaistar.VoteAwardInfo")
local CSetAward = class("CSetAward")
CSetAward.TYPEID = 12612354
function CSetAward:ctor(client_yuanbao, vote_award_info, vote_num)
  self.id = 12612354
  self.client_yuanbao = client_yuanbao or nil
  self.vote_award_info = vote_award_info or VoteAwardInfo.new()
  self.vote_num = vote_num or nil
end
function CSetAward:marshal(os)
  os:marshalInt64(self.client_yuanbao)
  self.vote_award_info:marshal(os)
  os:marshalInt32(self.vote_num)
end
function CSetAward:unmarshal(os)
  self.client_yuanbao = os:unmarshalInt64()
  self.vote_award_info = VoteAwardInfo.new()
  self.vote_award_info:unmarshal(os)
  self.vote_num = os:unmarshalInt32()
end
function CSetAward:sizepolicy(size)
  return size <= 65535
end
return CSetAward
