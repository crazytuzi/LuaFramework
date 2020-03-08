local RolePartnerInfo = require("netio.protocol.mzm.gsp.partner.RolePartnerInfo")
local SPartnerLogginInfo = class("SPartnerLogginInfo")
SPartnerLogginInfo.TYPEID = 12588033
function SPartnerLogginInfo:ctor(rolePartnerInfo)
  self.id = 12588033
  self.rolePartnerInfo = rolePartnerInfo or RolePartnerInfo.new()
end
function SPartnerLogginInfo:marshal(os)
  self.rolePartnerInfo:marshal(os)
end
function SPartnerLogginInfo:unmarshal(os)
  self.rolePartnerInfo = RolePartnerInfo.new()
  self.rolePartnerInfo:unmarshal(os)
end
function SPartnerLogginInfo:sizepolicy(size)
  return size <= 65535
end
return SPartnerLogginInfo
