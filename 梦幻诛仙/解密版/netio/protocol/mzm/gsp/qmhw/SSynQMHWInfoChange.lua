local QMHWInfo = require("netio.protocol.mzm.gsp.qmhw.QMHWInfo")
local SSynQMHWInfoChange = class("SSynQMHWInfoChange")
SSynQMHWInfoChange.TYPEID = 12601870
function SSynQMHWInfoChange:ctor(qmhwInfo)
  self.id = 12601870
  self.qmhwInfo = qmhwInfo or QMHWInfo.new()
end
function SSynQMHWInfoChange:marshal(os)
  self.qmhwInfo:marshal(os)
end
function SSynQMHWInfoChange:unmarshal(os)
  self.qmhwInfo = QMHWInfo.new()
  self.qmhwInfo:unmarshal(os)
end
function SSynQMHWInfoChange:sizepolicy(size)
  return size <= 65535
end
return SSynQMHWInfoChange
