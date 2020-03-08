local LongJingTotalChangeInfo = require("netio.protocol.mzm.gsp.fabao.LongJingTotalChangeInfo")
local SSynLongJingChangeInfo = class("SSynLongJingChangeInfo")
SSynLongJingChangeInfo.TYPEID = 12595998
function SSynLongJingChangeInfo:ctor(longJingChangeInfo)
  self.id = 12595998
  self.longJingChangeInfo = longJingChangeInfo or LongJingTotalChangeInfo.new()
end
function SSynLongJingChangeInfo:marshal(os)
  self.longJingChangeInfo:marshal(os)
end
function SSynLongJingChangeInfo:unmarshal(os)
  self.longJingChangeInfo = LongJingTotalChangeInfo.new()
  self.longJingChangeInfo:unmarshal(os)
end
function SSynLongJingChangeInfo:sizepolicy(size)
  return size <= 65535
end
return SSynLongJingChangeInfo
