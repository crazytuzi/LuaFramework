local CEnterJiuXiaoMapReq = class("CEnterJiuXiaoMapReq")
CEnterJiuXiaoMapReq.TYPEID = 12595458
function CEnterJiuXiaoMapReq:ctor()
  self.id = 12595458
end
function CEnterJiuXiaoMapReq:marshal(os)
end
function CEnterJiuXiaoMapReq:unmarshal(os)
end
function CEnterJiuXiaoMapReq:sizepolicy(size)
  return size <= 65535
end
return CEnterJiuXiaoMapReq
