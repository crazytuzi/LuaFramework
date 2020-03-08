local CCollectFireworkReq = class("CCollectFireworkReq")
CCollectFireworkReq.TYPEID = 12625161
function CCollectFireworkReq:ctor(instanceId)
  self.id = 12625161
  self.instanceId = instanceId or nil
end
function CCollectFireworkReq:marshal(os)
  os:marshalInt32(self.instanceId)
end
function CCollectFireworkReq:unmarshal(os)
  self.instanceId = os:unmarshalInt32()
end
function CCollectFireworkReq:sizepolicy(size)
  return size <= 65535
end
return CCollectFireworkReq
