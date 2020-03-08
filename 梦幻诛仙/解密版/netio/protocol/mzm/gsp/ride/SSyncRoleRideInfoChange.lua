local RideInfo = require("netio.protocol.mzm.gsp.ride.RideInfo")
local SSyncRoleRideInfoChange = class("SSyncRoleRideInfoChange")
SSyncRoleRideInfoChange.TYPEID = 797955
function SSyncRoleRideInfoChange:ctor(rideInfo)
  self.id = 797955
  self.rideInfo = rideInfo or RideInfo.new()
end
function SSyncRoleRideInfoChange:marshal(os)
  self.rideInfo:marshal(os)
end
function SSyncRoleRideInfoChange:unmarshal(os)
  self.rideInfo = RideInfo.new()
  self.rideInfo:unmarshal(os)
end
function SSyncRoleRideInfoChange:sizepolicy(size)
  return size <= 65535
end
return SSyncRoleRideInfoChange
