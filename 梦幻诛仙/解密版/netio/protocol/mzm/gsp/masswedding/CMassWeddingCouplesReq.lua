local CMassWeddingCouplesReq = class("CMassWeddingCouplesReq")
CMassWeddingCouplesReq.TYPEID = 12604947
function CMassWeddingCouplesReq:ctor()
  self.id = 12604947
end
function CMassWeddingCouplesReq:marshal(os)
end
function CMassWeddingCouplesReq:unmarshal(os)
end
function CMassWeddingCouplesReq:sizepolicy(size)
  return size <= 65535
end
return CMassWeddingCouplesReq
