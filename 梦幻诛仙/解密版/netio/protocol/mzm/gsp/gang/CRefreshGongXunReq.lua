local CRefreshGongXunReq = class("CRefreshGongXunReq")
CRefreshGongXunReq.TYPEID = 12589960
function CRefreshGongXunReq:ctor()
  self.id = 12589960
end
function CRefreshGongXunReq:marshal(os)
end
function CRefreshGongXunReq:unmarshal(os)
end
function CRefreshGongXunReq:sizepolicy(size)
  return size <= 65535
end
return CRefreshGongXunReq
