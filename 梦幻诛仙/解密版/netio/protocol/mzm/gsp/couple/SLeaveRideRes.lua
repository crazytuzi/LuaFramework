local SLeaveRideRes = class("SLeaveRideRes")
SLeaveRideRes.TYPEID = 12600579
function SLeaveRideRes:ctor()
  self.id = 12600579
end
function SLeaveRideRes:marshal(os)
end
function SLeaveRideRes:unmarshal(os)
end
function SLeaveRideRes:sizepolicy(size)
  return size <= 65535
end
return SLeaveRideRes
