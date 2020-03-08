local CJoinDianShiReq = class("CJoinDianShiReq")
CJoinDianShiReq.TYPEID = 12594707
function CJoinDianShiReq:ctor()
  self.id = 12594707
end
function CJoinDianShiReq:marshal(os)
end
function CJoinDianShiReq:unmarshal(os)
end
function CJoinDianShiReq:sizepolicy(size)
  return size <= 65535
end
return CJoinDianShiReq
