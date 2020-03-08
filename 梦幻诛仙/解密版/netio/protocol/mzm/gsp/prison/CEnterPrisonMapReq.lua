local CEnterPrisonMapReq = class("CEnterPrisonMapReq")
CEnterPrisonMapReq.TYPEID = 12620036
function CEnterPrisonMapReq:ctor()
  self.id = 12620036
end
function CEnterPrisonMapReq:marshal(os)
end
function CEnterPrisonMapReq:unmarshal(os)
end
function CEnterPrisonMapReq:sizepolicy(size)
  return size <= 65535
end
return CEnterPrisonMapReq
