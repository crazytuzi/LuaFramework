local CVigorWorkReq = class("CVigorWorkReq")
CVigorWorkReq.TYPEID = 12585998
function CVigorWorkReq:ctor()
  self.id = 12585998
end
function CVigorWorkReq:marshal(os)
end
function CVigorWorkReq:unmarshal(os)
end
function CVigorWorkReq:sizepolicy(size)
  return size <= 65535
end
return CVigorWorkReq
