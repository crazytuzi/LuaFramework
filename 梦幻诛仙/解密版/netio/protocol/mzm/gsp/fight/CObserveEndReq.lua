local CObserveEndReq = class("CObserveEndReq")
CObserveEndReq.TYPEID = 12594177
function CObserveEndReq:ctor()
  self.id = 12594177
end
function CObserveEndReq:marshal(os)
end
function CObserveEndReq:unmarshal(os)
end
function CObserveEndReq:sizepolicy(size)
  return size <= 65535
end
return CObserveEndReq
