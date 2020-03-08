local CorpsMemberSynInfo = require("netio.protocol.mzm.gsp.corps.CorpsMemberSynInfo")
local SNewMemberJoinCorpsBro = class("SNewMemberJoinCorpsBro")
SNewMemberJoinCorpsBro.TYPEID = 12617481
function SNewMemberJoinCorpsBro:ctor(newMember)
  self.id = 12617481
  self.newMember = newMember or CorpsMemberSynInfo.new()
end
function SNewMemberJoinCorpsBro:marshal(os)
  self.newMember:marshal(os)
end
function SNewMemberJoinCorpsBro:unmarshal(os)
  self.newMember = CorpsMemberSynInfo.new()
  self.newMember:unmarshal(os)
end
function SNewMemberJoinCorpsBro:sizepolicy(size)
  return size <= 65535
end
return SNewMemberJoinCorpsBro
