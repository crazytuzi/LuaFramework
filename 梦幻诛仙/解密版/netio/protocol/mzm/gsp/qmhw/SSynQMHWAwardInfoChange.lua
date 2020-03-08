local QMHWAwardInfo = require("netio.protocol.mzm.gsp.qmhw.QMHWAwardInfo")
local SSynQMHWAwardInfoChange = class("SSynQMHWAwardInfoChange")
SSynQMHWAwardInfoChange.TYPEID = 12601861
function SSynQMHWAwardInfoChange:ctor(qmhwAwardInfo)
  self.id = 12601861
  self.qmhwAwardInfo = qmhwAwardInfo or QMHWAwardInfo.new()
end
function SSynQMHWAwardInfoChange:marshal(os)
  self.qmhwAwardInfo:marshal(os)
end
function SSynQMHWAwardInfoChange:unmarshal(os)
  self.qmhwAwardInfo = QMHWAwardInfo.new()
  self.qmhwAwardInfo:unmarshal(os)
end
function SSynQMHWAwardInfoChange:sizepolicy(size)
  return size <= 65535
end
return SSynQMHWAwardInfoChange
