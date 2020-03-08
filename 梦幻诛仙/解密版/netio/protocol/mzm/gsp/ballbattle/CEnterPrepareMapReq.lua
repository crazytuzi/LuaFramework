local CEnterPrepareMapReq = class("CEnterPrepareMapReq")
CEnterPrepareMapReq.TYPEID = 12629264
function CEnterPrepareMapReq:ctor()
  self.id = 12629264
end
function CEnterPrepareMapReq:marshal(os)
end
function CEnterPrepareMapReq:unmarshal(os)
end
function CEnterPrepareMapReq:sizepolicy(size)
  return size <= 65535
end
return CEnterPrepareMapReq
