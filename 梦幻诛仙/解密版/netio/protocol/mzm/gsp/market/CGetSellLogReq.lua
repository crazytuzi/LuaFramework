local CGetSellLogReq = class("CGetSellLogReq")
CGetSellLogReq.TYPEID = 12601438
function CGetSellLogReq:ctor()
  self.id = 12601438
end
function CGetSellLogReq:marshal(os)
end
function CGetSellLogReq:unmarshal(os)
end
function CGetSellLogReq:sizepolicy(size)
  return size <= 65535
end
return CGetSellLogReq
