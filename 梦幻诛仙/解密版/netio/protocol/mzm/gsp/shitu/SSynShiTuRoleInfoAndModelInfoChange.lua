local ShiTuRoleInfoAndModelInfo = require("netio.protocol.mzm.gsp.shitu.ShiTuRoleInfoAndModelInfo")
local SSynShiTuRoleInfoAndModelInfoChange = class("SSynShiTuRoleInfoAndModelInfoChange")
SSynShiTuRoleInfoAndModelInfoChange.TYPEID = 12601635
function SSynShiTuRoleInfoAndModelInfoChange:ctor(changeInfo)
  self.id = 12601635
  self.changeInfo = changeInfo or ShiTuRoleInfoAndModelInfo.new()
end
function SSynShiTuRoleInfoAndModelInfoChange:marshal(os)
  self.changeInfo:marshal(os)
end
function SSynShiTuRoleInfoAndModelInfoChange:unmarshal(os)
  self.changeInfo = ShiTuRoleInfoAndModelInfo.new()
  self.changeInfo:unmarshal(os)
end
function SSynShiTuRoleInfoAndModelInfoChange:sizepolicy(size)
  return size <= 65535
end
return SSynShiTuRoleInfoAndModelInfoChange
