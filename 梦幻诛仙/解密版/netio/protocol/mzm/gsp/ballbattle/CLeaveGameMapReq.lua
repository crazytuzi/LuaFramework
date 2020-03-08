local CLeaveGameMapReq = class("CLeaveGameMapReq")
CLeaveGameMapReq.TYPEID = 12629261
function CLeaveGameMapReq:ctor()
  self.id = 12629261
end
function CLeaveGameMapReq:marshal(os)
end
function CLeaveGameMapReq:unmarshal(os)
end
function CLeaveGameMapReq:sizepolicy(size)
  return size <= 65535
end
return CLeaveGameMapReq
