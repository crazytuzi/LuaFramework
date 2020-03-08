local CLeaveInstanceReq = class("CLeaveInstanceReq")
CLeaveInstanceReq.TYPEID = 12591368
function CLeaveInstanceReq:ctor()
  self.id = 12591368
end
function CLeaveInstanceReq:marshal(os)
end
function CLeaveInstanceReq:unmarshal(os)
end
function CLeaveInstanceReq:sizepolicy(size)
  return size <= 65535
end
return CLeaveInstanceReq
