local CLeaveSwornReq = class("CLeaveSwornReq")
CLeaveSwornReq.TYPEID = 12597803
function CLeaveSwornReq:ctor()
  self.id = 12597803
end
function CLeaveSwornReq:marshal(os)
end
function CLeaveSwornReq:unmarshal(os)
end
function CLeaveSwornReq:sizepolicy(size)
  return size <= 65535
end
return CLeaveSwornReq
