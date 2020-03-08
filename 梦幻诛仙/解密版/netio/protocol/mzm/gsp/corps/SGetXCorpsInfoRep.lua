local CorpsInfo = require("netio.protocol.mzm.gsp.corps.CorpsInfo")
local SGetXCorpsInfoRep = class("SGetXCorpsInfoRep")
SGetXCorpsInfoRep.TYPEID = 12617512
function SGetXCorpsInfoRep:ctor(corpsInfo)
  self.id = 12617512
  self.corpsInfo = corpsInfo or CorpsInfo.new()
end
function SGetXCorpsInfoRep:marshal(os)
  self.corpsInfo:marshal(os)
end
function SGetXCorpsInfoRep:unmarshal(os)
  self.corpsInfo = CorpsInfo.new()
  self.corpsInfo:unmarshal(os)
end
function SGetXCorpsInfoRep:sizepolicy(size)
  return size <= 65535
end
return SGetXCorpsInfoRep
