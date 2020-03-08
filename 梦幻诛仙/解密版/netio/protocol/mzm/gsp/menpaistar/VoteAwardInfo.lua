local OctetsStream = require("netio.OctetsStream")
local VoteAwardInfo = class("VoteAwardInfo")
function VoteAwardInfo:ctor(award, num)
  self.award = award or nil
  self.num = num or nil
end
function VoteAwardInfo:marshal(os)
  os:marshalInt32(self.award)
  os:marshalInt32(self.num)
end
function VoteAwardInfo:unmarshal(os)
  self.award = os:unmarshalInt32()
  self.num = os:unmarshalInt32()
end
return VoteAwardInfo
