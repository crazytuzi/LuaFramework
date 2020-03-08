local OctetsStream = require("netio.OctetsStream")
local CorpsMember = require("netio.protocol.mzm.gsp.corps.CorpsMember")
local CorpsMemberExtroInfo = require("netio.protocol.mzm.gsp.corps.CorpsMemberExtroInfo")
local CorpsMemberSynInfo = class("CorpsMemberSynInfo")
function CorpsMemberSynInfo:ctor(baseInfo, extroInfo)
  self.baseInfo = baseInfo or CorpsMember.new()
  self.extroInfo = extroInfo or CorpsMemberExtroInfo.new()
end
function CorpsMemberSynInfo:marshal(os)
  self.baseInfo:marshal(os)
  self.extroInfo:marshal(os)
end
function CorpsMemberSynInfo:unmarshal(os)
  self.baseInfo = CorpsMember.new()
  self.baseInfo:unmarshal(os)
  self.extroInfo = CorpsMemberExtroInfo.new()
  self.extroInfo:unmarshal(os)
end
return CorpsMemberSynInfo
