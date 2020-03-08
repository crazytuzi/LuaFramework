local CSelfRankReq = class("CSelfRankReq")
CSelfRankReq.TYPEID = 12596739
function CSelfRankReq:ctor()
  self.id = 12596739
end
function CSelfRankReq:marshal(os)
end
function CSelfRankReq:unmarshal(os)
end
function CSelfRankReq:sizepolicy(size)
  return size <= 65535
end
return CSelfRankReq
