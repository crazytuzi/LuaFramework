local MiFangInfo = require("netio.protocol.mzm.gsp.gang.MiFangInfo")
local SSyncGangMiFangInfo = class("SSyncGangMiFangInfo")
SSyncGangMiFangInfo.TYPEID = 12589923
function SSyncGangMiFangInfo:ctor(miFangInfo)
  self.id = 12589923
  self.miFangInfo = miFangInfo or MiFangInfo.new()
end
function SSyncGangMiFangInfo:marshal(os)
  self.miFangInfo:marshal(os)
end
function SSyncGangMiFangInfo:unmarshal(os)
  self.miFangInfo = MiFangInfo.new()
  self.miFangInfo:unmarshal(os)
end
function SSyncGangMiFangInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncGangMiFangInfo
