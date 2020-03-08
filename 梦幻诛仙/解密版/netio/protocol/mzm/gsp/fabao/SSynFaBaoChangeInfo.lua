local FaBaoChangeInfo = require("netio.protocol.mzm.gsp.fabao.FaBaoChangeInfo")
local SSynFaBaoChangeInfo = class("SSynFaBaoChangeInfo")
SSynFaBaoChangeInfo.TYPEID = 12596003
function SSynFaBaoChangeInfo:ctor(fabaoChangeInfo)
  self.id = 12596003
  self.fabaoChangeInfo = fabaoChangeInfo or FaBaoChangeInfo.new()
end
function SSynFaBaoChangeInfo:marshal(os)
  self.fabaoChangeInfo:marshal(os)
end
function SSynFaBaoChangeInfo:unmarshal(os)
  self.fabaoChangeInfo = FaBaoChangeInfo.new()
  self.fabaoChangeInfo:unmarshal(os)
end
function SSynFaBaoChangeInfo:sizepolicy(size)
  return size <= 65535
end
return SSynFaBaoChangeInfo
