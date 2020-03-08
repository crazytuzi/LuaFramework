local CUseDoublePointReq = class("CUseDoublePointReq")
CUseDoublePointReq.TYPEID = 12584744
function CUseDoublePointReq:ctor(uuid)
  self.id = 12584744
  self.uuid = uuid or nil
end
function CUseDoublePointReq:marshal(os)
  os:marshalInt64(self.uuid)
end
function CUseDoublePointReq:unmarshal(os)
  self.uuid = os:unmarshalInt64()
end
function CUseDoublePointReq:sizepolicy(size)
  return size <= 65535
end
return CUseDoublePointReq
