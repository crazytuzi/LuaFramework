local WingData = require("netio.protocol.mzm.gsp.wing.WingData")
local SAddWingRankRep = class("SAddWingRankRep")
SAddWingRankRep.TYPEID = 12596538
function SAddWingRankRep:ctor(wing)
  self.id = 12596538
  self.wing = wing or WingData.new()
end
function SAddWingRankRep:marshal(os)
  self.wing:marshal(os)
end
function SAddWingRankRep:unmarshal(os)
  self.wing = WingData.new()
  self.wing:unmarshal(os)
end
function SAddWingRankRep:sizepolicy(size)
  return size <= 65535
end
return SAddWingRankRep
