local CLeaveRideReq = class("CLeaveRideReq")
CLeaveRideReq.TYPEID = 12600581
function CLeaveRideReq:ctor()
  self.id = 12600581
end
function CLeaveRideReq:marshal(os)
end
function CLeaveRideReq:unmarshal(os)
end
function CLeaveRideReq:sizepolicy(size)
  return size <= 65535
end
return CLeaveRideReq
