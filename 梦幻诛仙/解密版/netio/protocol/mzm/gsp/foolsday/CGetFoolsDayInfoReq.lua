local CGetFoolsDayInfoReq = class("CGetFoolsDayInfoReq")
CGetFoolsDayInfoReq.TYPEID = 12612868
function CGetFoolsDayInfoReq:ctor()
  self.id = 12612868
end
function CGetFoolsDayInfoReq:marshal(os)
end
function CGetFoolsDayInfoReq:unmarshal(os)
end
function CGetFoolsDayInfoReq:sizepolicy(size)
  return size <= 65535
end
return CGetFoolsDayInfoReq
