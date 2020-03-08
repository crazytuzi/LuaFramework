local CorpsBriefInfo = require("netio.protocol.mzm.gsp.corps.CorpsBriefInfo")
local SGetXCorpsBriefInfoRep = class("SGetXCorpsBriefInfoRep")
SGetXCorpsBriefInfoRep.TYPEID = 12617514
function SGetXCorpsBriefInfoRep:ctor(corpsBriefInfo)
  self.id = 12617514
  self.corpsBriefInfo = corpsBriefInfo or CorpsBriefInfo.new()
end
function SGetXCorpsBriefInfoRep:marshal(os)
  self.corpsBriefInfo:marshal(os)
end
function SGetXCorpsBriefInfoRep:unmarshal(os)
  self.corpsBriefInfo = CorpsBriefInfo.new()
  self.corpsBriefInfo:unmarshal(os)
end
function SGetXCorpsBriefInfoRep:sizepolicy(size)
  return size <= 65535
end
return SGetXCorpsBriefInfoRep
