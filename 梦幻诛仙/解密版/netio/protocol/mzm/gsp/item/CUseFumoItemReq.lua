local CUseFumoItemReq = class("CUseFumoItemReq")
CUseFumoItemReq.TYPEID = 12584718
function CUseFumoItemReq:ctor(uuid)
  self.id = 12584718
  self.uuid = uuid or nil
end
function CUseFumoItemReq:marshal(os)
  os:marshalInt64(self.uuid)
end
function CUseFumoItemReq:unmarshal(os)
  self.uuid = os:unmarshalInt64()
end
function CUseFumoItemReq:sizepolicy(size)
  return size <= 65535
end
return CUseFumoItemReq
