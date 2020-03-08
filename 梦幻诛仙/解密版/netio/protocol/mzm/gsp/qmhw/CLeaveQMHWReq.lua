local CLeaveQMHWReq = class("CLeaveQMHWReq")
CLeaveQMHWReq.TYPEID = 12601858
function CLeaveQMHWReq:ctor()
  self.id = 12601858
end
function CLeaveQMHWReq:marshal(os)
end
function CLeaveQMHWReq:unmarshal(os)
end
function CLeaveQMHWReq:sizepolicy(size)
  return size <= 65535
end
return CLeaveQMHWReq
