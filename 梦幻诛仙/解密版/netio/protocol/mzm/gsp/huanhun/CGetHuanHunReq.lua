local CGetHuanHunReq = class("CGetHuanHunReq")
CGetHuanHunReq.TYPEID = 12584459
function CGetHuanHunReq:ctor()
  self.id = 12584459
end
function CGetHuanHunReq:marshal(os)
end
function CGetHuanHunReq:unmarshal(os)
end
function CGetHuanHunReq:sizepolicy(size)
  return size <= 65535
end
return CGetHuanHunReq
