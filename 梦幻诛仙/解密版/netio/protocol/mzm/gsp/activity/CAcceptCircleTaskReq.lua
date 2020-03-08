local CAcceptCircleTaskReq = class("CAcceptCircleTaskReq")
CAcceptCircleTaskReq.TYPEID = 12587539
function CAcceptCircleTaskReq:ctor()
  self.id = 12587539
end
function CAcceptCircleTaskReq:marshal(os)
end
function CAcceptCircleTaskReq:unmarshal(os)
end
function CAcceptCircleTaskReq:sizepolicy(size)
  return size <= 65535
end
return CAcceptCircleTaskReq
