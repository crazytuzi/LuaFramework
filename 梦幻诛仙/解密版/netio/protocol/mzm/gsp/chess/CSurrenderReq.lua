local CSurrenderReq = class("CSurrenderReq")
CSurrenderReq.TYPEID = 12619009
function CSurrenderReq:ctor()
  self.id = 12619009
end
function CSurrenderReq:marshal(os)
end
function CSurrenderReq:unmarshal(os)
end
function CSurrenderReq:sizepolicy(size)
  return size <= 65535
end
return CSurrenderReq
