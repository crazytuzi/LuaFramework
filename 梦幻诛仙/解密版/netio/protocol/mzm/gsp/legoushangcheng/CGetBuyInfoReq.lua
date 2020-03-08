local CGetBuyInfoReq = class("CGetBuyInfoReq")
CGetBuyInfoReq.TYPEID = 12621317
function CGetBuyInfoReq:ctor()
  self.id = 12621317
end
function CGetBuyInfoReq:marshal(os)
end
function CGetBuyInfoReq:unmarshal(os)
end
function CGetBuyInfoReq:sizepolicy(size)
  return size <= 65535
end
return CGetBuyInfoReq
