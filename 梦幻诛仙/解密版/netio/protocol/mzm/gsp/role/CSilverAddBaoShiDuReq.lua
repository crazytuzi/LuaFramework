local CSilverAddBaoShiDuReq = class("CSilverAddBaoShiDuReq")
CSilverAddBaoShiDuReq.TYPEID = 12586002
function CSilverAddBaoShiDuReq:ctor()
  self.id = 12586002
end
function CSilverAddBaoShiDuReq:marshal(os)
end
function CSilverAddBaoShiDuReq:unmarshal(os)
end
function CSilverAddBaoShiDuReq:sizepolicy(size)
  return size <= 65535
end
return CSilverAddBaoShiDuReq
