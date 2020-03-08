local CLeaveArenaMapReq = class("CLeaveArenaMapReq")
CLeaveArenaMapReq.TYPEID = 12596738
function CLeaveArenaMapReq:ctor()
  self.id = 12596738
end
function CLeaveArenaMapReq:marshal(os)
end
function CLeaveArenaMapReq:unmarshal(os)
end
function CLeaveArenaMapReq:sizepolicy(size)
  return size <= 65535
end
return CLeaveArenaMapReq
