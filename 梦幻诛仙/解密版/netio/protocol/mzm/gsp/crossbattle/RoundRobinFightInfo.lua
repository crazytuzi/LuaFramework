local OctetsStream = require("netio.OctetsStream")
local CorpsBriefInfo = require("netio.protocol.mzm.gsp.crossbattle.CorpsBriefInfo")
local RoundRobinFightInfo = class("RoundRobinFightInfo")
RoundRobinFightInfo.STATE_NOT_START = 0
RoundRobinFightInfo.STATE_FIGHTING = 1
RoundRobinFightInfo.STATE_A_WIN = 2
RoundRobinFightInfo.STATE_B_WIN = 3
RoundRobinFightInfo.STATE_A_ABSTAIN = 4
RoundRobinFightInfo.STATE_B_ABSTAIN = 5
RoundRobinFightInfo.STATE_ALL_ABSTAIN = 6
RoundRobinFightInfo.STATE_EXCEPTION_END = 7
function RoundRobinFightInfo:ctor(corps_a_brief_info, corps_b_brief_info, state)
  self.corps_a_brief_info = corps_a_brief_info or CorpsBriefInfo.new()
  self.corps_b_brief_info = corps_b_brief_info or CorpsBriefInfo.new()
  self.state = state or nil
end
function RoundRobinFightInfo:marshal(os)
  self.corps_a_brief_info:marshal(os)
  self.corps_b_brief_info:marshal(os)
  os:marshalInt32(self.state)
end
function RoundRobinFightInfo:unmarshal(os)
  self.corps_a_brief_info = CorpsBriefInfo.new()
  self.corps_a_brief_info:unmarshal(os)
  self.corps_b_brief_info = CorpsBriefInfo.new()
  self.corps_b_brief_info:unmarshal(os)
  self.state = os:unmarshalInt32()
end
return RoundRobinFightInfo
