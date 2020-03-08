local QMHWInfo = require("netio.protocol.mzm.gsp.qmhw.QMHWInfo")
local QMHWAwardInfo = require("netio.protocol.mzm.gsp.qmhw.QMHWAwardInfo")
local SSynRoleQMHWToTalInfo = class("SSynRoleQMHWToTalInfo")
SSynRoleQMHWToTalInfo.TYPEID = 12601859
function SSynRoleQMHWToTalInfo:ctor(qmhwInfo, awardInfo)
  self.id = 12601859
  self.qmhwInfo = qmhwInfo or QMHWInfo.new()
  self.awardInfo = awardInfo or QMHWAwardInfo.new()
end
function SSynRoleQMHWToTalInfo:marshal(os)
  self.qmhwInfo:marshal(os)
  self.awardInfo:marshal(os)
end
function SSynRoleQMHWToTalInfo:unmarshal(os)
  self.qmhwInfo = QMHWInfo.new()
  self.qmhwInfo:unmarshal(os)
  self.awardInfo = QMHWAwardInfo.new()
  self.awardInfo:unmarshal(os)
end
function SSynRoleQMHWToTalInfo:sizepolicy(size)
  return size <= 65535
end
return SSynRoleQMHWToTalInfo
