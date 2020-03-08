local CEnterCrossCompeteMapReq = class("CEnterCrossCompeteMapReq")
CEnterCrossCompeteMapReq.TYPEID = 12616736
function CEnterCrossCompeteMapReq:ctor()
  self.id = 12616736
end
function CEnterCrossCompeteMapReq:marshal(os)
end
function CEnterCrossCompeteMapReq:unmarshal(os)
end
function CEnterCrossCompeteMapReq:sizepolicy(size)
  return size <= 65535
end
return CEnterCrossCompeteMapReq
