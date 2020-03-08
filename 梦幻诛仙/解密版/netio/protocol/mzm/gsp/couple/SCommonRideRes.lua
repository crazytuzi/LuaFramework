local CommonRideRoleInfo = require("netio.protocol.mzm.gsp.couple.CommonRideRoleInfo")
local SCommonRideRes = class("SCommonRideRes")
SCommonRideRes.TYPEID = 12600580
function SCommonRideRes:ctor(commonRideRoleInfo)
  self.id = 12600580
  self.commonRideRoleInfo = commonRideRoleInfo or CommonRideRoleInfo.new()
end
function SCommonRideRes:marshal(os)
  self.commonRideRoleInfo:marshal(os)
end
function SCommonRideRes:unmarshal(os)
  self.commonRideRoleInfo = CommonRideRoleInfo.new()
  self.commonRideRoleInfo:unmarshal(os)
end
function SCommonRideRes:sizepolicy(size)
  return size <= 65535
end
return SCommonRideRes
