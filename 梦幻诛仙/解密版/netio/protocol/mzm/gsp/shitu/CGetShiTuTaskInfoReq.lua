local CGetShiTuTaskInfoReq = class("CGetShiTuTaskInfoReq")
CGetShiTuTaskInfoReq.TYPEID = 12601638
function CGetShiTuTaskInfoReq:ctor()
  self.id = 12601638
end
function CGetShiTuTaskInfoReq:marshal(os)
end
function CGetShiTuTaskInfoReq:unmarshal(os)
end
function CGetShiTuTaskInfoReq:sizepolicy(size)
  return size <= 65535
end
return CGetShiTuTaskInfoReq
