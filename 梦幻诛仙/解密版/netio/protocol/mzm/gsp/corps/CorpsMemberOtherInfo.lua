local OctetsStream = require("netio.OctetsStream")
local CorpsMemberOtherInfo = class("CorpsMemberOtherInfo")
function CorpsMemberOtherInfo:ctor(multiFightValue, mfvRank)
  self.multiFightValue = multiFightValue or nil
  self.mfvRank = mfvRank or nil
end
function CorpsMemberOtherInfo:marshal(os)
  os:marshalInt32(self.multiFightValue)
  os:marshalInt32(self.mfvRank)
end
function CorpsMemberOtherInfo:unmarshal(os)
  self.multiFightValue = os:unmarshalInt32()
  self.mfvRank = os:unmarshalInt32()
end
return CorpsMemberOtherInfo
