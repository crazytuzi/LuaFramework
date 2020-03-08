local OctetsStream = require("netio.OctetsStream")
local CorpsMember = require("netio.protocol.mzm.gsp.corps.CorpsMember")
local CorpsMemberOtherInfo = require("netio.protocol.mzm.gsp.corps.CorpsMemberOtherInfo")
local CorpsMemberDetailInfo = class("CorpsMemberDetailInfo")
function CorpsMemberDetailInfo:ctor(baseInfo, otherInfo)
  self.baseInfo = baseInfo or CorpsMember.new()
  self.otherInfo = otherInfo or CorpsMemberOtherInfo.new()
end
function CorpsMemberDetailInfo:marshal(os)
  self.baseInfo:marshal(os)
  self.otherInfo:marshal(os)
end
function CorpsMemberDetailInfo:unmarshal(os)
  self.baseInfo = CorpsMember.new()
  self.baseInfo:unmarshal(os)
  self.otherInfo = CorpsMemberOtherInfo.new()
  self.otherInfo:unmarshal(os)
end
return CorpsMemberDetailInfo
