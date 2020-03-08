local CorpsDetailInfo = require("netio.protocol.mzm.gsp.corps.CorpsDetailInfo")
local SGetCorpsDetailInfoRep = class("SGetCorpsDetailInfoRep")
SGetCorpsDetailInfoRep.TYPEID = 12617517
function SGetCorpsDetailInfoRep:ctor(corpsDetailInfo)
  self.id = 12617517
  self.corpsDetailInfo = corpsDetailInfo or CorpsDetailInfo.new()
end
function SGetCorpsDetailInfoRep:marshal(os)
  self.corpsDetailInfo:marshal(os)
end
function SGetCorpsDetailInfoRep:unmarshal(os)
  self.corpsDetailInfo = CorpsDetailInfo.new()
  self.corpsDetailInfo:unmarshal(os)
end
function SGetCorpsDetailInfoRep:sizepolicy(size)
  return size <= 65535
end
return SGetCorpsDetailInfoRep
