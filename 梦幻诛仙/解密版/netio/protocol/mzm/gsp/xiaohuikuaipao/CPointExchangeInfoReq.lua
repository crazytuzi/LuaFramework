local CPointExchangeInfoReq = class("CPointExchangeInfoReq")
CPointExchangeInfoReq.TYPEID = 12622857
function CPointExchangeInfoReq:ctor()
  self.id = 12622857
end
function CPointExchangeInfoReq:marshal(os)
end
function CPointExchangeInfoReq:unmarshal(os)
end
function CPointExchangeInfoReq:sizepolicy(size)
  return size <= 65535
end
return CPointExchangeInfoReq
