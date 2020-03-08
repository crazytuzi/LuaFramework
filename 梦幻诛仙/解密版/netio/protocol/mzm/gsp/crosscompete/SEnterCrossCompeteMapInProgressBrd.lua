local Against = require("netio.protocol.mzm.gsp.crosscompete.Against")
local SEnterCrossCompeteMapInProgressBrd = class("SEnterCrossCompeteMapInProgressBrd")
SEnterCrossCompeteMapInProgressBrd.TYPEID = 12616738
function SEnterCrossCompeteMapInProgressBrd:ctor(against)
  self.id = 12616738
  self.against = against or Against.new()
end
function SEnterCrossCompeteMapInProgressBrd:marshal(os)
  self.against:marshal(os)
end
function SEnterCrossCompeteMapInProgressBrd:unmarshal(os)
  self.against = Against.new()
  self.against:unmarshal(os)
end
function SEnterCrossCompeteMapInProgressBrd:sizepolicy(size)
  return size <= 65535
end
return SEnterCrossCompeteMapInProgressBrd
