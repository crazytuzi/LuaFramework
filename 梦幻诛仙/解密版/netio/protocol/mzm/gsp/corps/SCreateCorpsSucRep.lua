local CorpsSynInfo = require("netio.protocol.mzm.gsp.corps.CorpsSynInfo")
local SCreateCorpsSucRep = class("SCreateCorpsSucRep")
SCreateCorpsSucRep.TYPEID = 12617498
function SCreateCorpsSucRep:ctor(corpsInfo)
  self.id = 12617498
  self.corpsInfo = corpsInfo or CorpsSynInfo.new()
end
function SCreateCorpsSucRep:marshal(os)
  self.corpsInfo:marshal(os)
end
function SCreateCorpsSucRep:unmarshal(os)
  self.corpsInfo = CorpsSynInfo.new()
  self.corpsInfo:unmarshal(os)
end
function SCreateCorpsSucRep:sizepolicy(size)
  return size <= 65535
end
return SCreateCorpsSucRep
