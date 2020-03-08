local CGetShiTuActiveInfoReq = class("CGetShiTuActiveInfoReq")
CGetShiTuActiveInfoReq.TYPEID = 12601653
function CGetShiTuActiveInfoReq:ctor()
  self.id = 12601653
end
function CGetShiTuActiveInfoReq:marshal(os)
end
function CGetShiTuActiveInfoReq:unmarshal(os)
end
function CGetShiTuActiveInfoReq:sizepolicy(size)
  return size <= 65535
end
return CGetShiTuActiveInfoReq
