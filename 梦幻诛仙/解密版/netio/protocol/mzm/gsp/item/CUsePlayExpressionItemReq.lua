local CUsePlayExpressionItemReq = class("CUsePlayExpressionItemReq")
CUsePlayExpressionItemReq.TYPEID = 12584850
function CUsePlayExpressionItemReq:ctor(uuid)
  self.id = 12584850
  self.uuid = uuid or nil
end
function CUsePlayExpressionItemReq:marshal(os)
  os:marshalInt64(self.uuid)
end
function CUsePlayExpressionItemReq:unmarshal(os)
  self.uuid = os:unmarshalInt64()
end
function CUsePlayExpressionItemReq:sizepolicy(size)
  return size <= 65535
end
return CUsePlayExpressionItemReq
