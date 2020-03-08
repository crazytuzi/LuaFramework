local CShouTuReq = class("CShouTuReq")
CShouTuReq.TYPEID = 12601601
function CShouTuReq:ctor()
  self.id = 12601601
end
function CShouTuReq:marshal(os)
end
function CShouTuReq:unmarshal(os)
end
function CShouTuReq:sizepolicy(size)
  return size <= 65535
end
return CShouTuReq
