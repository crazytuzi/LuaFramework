local CQueryAllConcernReq = class("CQueryAllConcernReq")
CQueryAllConcernReq.TYPEID = 12601382
function CQueryAllConcernReq:ctor()
  self.id = 12601382
end
function CQueryAllConcernReq:marshal(os)
end
function CQueryAllConcernReq:unmarshal(os)
end
function CQueryAllConcernReq:sizepolicy(size)
  return size <= 65535
end
return CQueryAllConcernReq
