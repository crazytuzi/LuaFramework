local CGetRunningInfoReq = class("CGetRunningInfoReq")
CGetRunningInfoReq.TYPEID = 12602116
function CGetRunningInfoReq:ctor()
  self.id = 12602116
end
function CGetRunningInfoReq:marshal(os)
end
function CGetRunningInfoReq:unmarshal(os)
end
function CGetRunningInfoReq:sizepolicy(size)
  return size <= 65535
end
return CGetRunningInfoReq
