local FactionMakeUpInfo = require("netio.protocol.mzm.gsp.makeup.FactionMakeUpInfo")
local RoleMakeUpInfo = require("netio.protocol.mzm.gsp.makeup.RoleMakeUpInfo")
local SSynMakeupInfo = class("SSynMakeupInfo")
SSynMakeupInfo.TYPEID = 12625926
function SSynMakeupInfo:ctor(factionMakeupInfo, roleMakeupInfo)
  self.id = 12625926
  self.factionMakeupInfo = factionMakeupInfo or FactionMakeUpInfo.new()
  self.roleMakeupInfo = roleMakeupInfo or RoleMakeUpInfo.new()
end
function SSynMakeupInfo:marshal(os)
  self.factionMakeupInfo:marshal(os)
  self.roleMakeupInfo:marshal(os)
end
function SSynMakeupInfo:unmarshal(os)
  self.factionMakeupInfo = FactionMakeUpInfo.new()
  self.factionMakeupInfo:unmarshal(os)
  self.roleMakeupInfo = RoleMakeUpInfo.new()
  self.roleMakeupInfo:unmarshal(os)
end
function SSynMakeupInfo:sizepolicy(size)
  return size <= 65535
end
return SSynMakeupInfo
