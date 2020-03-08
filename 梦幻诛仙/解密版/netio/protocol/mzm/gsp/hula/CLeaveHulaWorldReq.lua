local CLeaveHulaWorldReq = class("CLeaveHulaWorldReq")
CLeaveHulaWorldReq.TYPEID = 12608780
function CLeaveHulaWorldReq:ctor()
  self.id = 12608780
end
function CLeaveHulaWorldReq:marshal(os)
end
function CLeaveHulaWorldReq:unmarshal(os)
end
function CLeaveHulaWorldReq:sizepolicy(size)
  return size <= 65535
end
return CLeaveHulaWorldReq
