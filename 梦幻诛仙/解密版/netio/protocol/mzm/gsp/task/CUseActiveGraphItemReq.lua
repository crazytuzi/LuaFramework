local CUseActiveGraphItemReq = class("CUseActiveGraphItemReq")
CUseActiveGraphItemReq.TYPEID = 12592157
function CUseActiveGraphItemReq:ctor(uuid)
  self.id = 12592157
  self.uuid = uuid or nil
end
function CUseActiveGraphItemReq:marshal(os)
  os:marshalInt64(self.uuid)
end
function CUseActiveGraphItemReq:unmarshal(os)
  self.uuid = os:unmarshalInt64()
end
function CUseActiveGraphItemReq:sizepolicy(size)
  return size <= 65535
end
return CUseActiveGraphItemReq
