local CDivorceReq = class("CDivorceReq")
CDivorceReq.TYPEID = 12599810
function CDivorceReq:ctor()
  self.id = 12599810
end
function CDivorceReq:marshal(os)
end
function CDivorceReq:unmarshal(os)
end
function CDivorceReq:sizepolicy(size)
  return size <= 65535
end
return CDivorceReq
