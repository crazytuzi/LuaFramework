local WingData = require("netio.protocol.mzm.gsp.wing.WingData")
local SGetNewWing = class("SGetNewWing")
SGetNewWing.TYPEID = 12596540
function SGetNewWing:ctor(wing)
  self.id = 12596540
  self.wing = wing or WingData.new()
end
function SGetNewWing:marshal(os)
  self.wing:marshal(os)
end
function SGetNewWing:unmarshal(os)
  self.wing = WingData.new()
  self.wing:unmarshal(os)
end
function SGetNewWing:sizepolicy(size)
  return size <= 65535
end
return SGetNewWing
