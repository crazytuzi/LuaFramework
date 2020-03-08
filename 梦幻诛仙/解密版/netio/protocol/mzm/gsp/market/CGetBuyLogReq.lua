local CGetBuyLogReq = class("CGetBuyLogReq")
CGetBuyLogReq.TYPEID = 12601440
function CGetBuyLogReq:ctor()
  self.id = 12601440
end
function CGetBuyLogReq:marshal(os)
end
function CGetBuyLogReq:unmarshal(os)
end
function CGetBuyLogReq:sizepolicy(size)
  return size <= 65535
end
return CGetBuyLogReq
