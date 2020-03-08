local CDelFailureOrderReq = class("CDelFailureOrderReq")
CDelFailureOrderReq.TYPEID = 12588802
function CDelFailureOrderReq:ctor(gameOrderId)
  self.id = 12588802
  self.gameOrderId = gameOrderId or nil
end
function CDelFailureOrderReq:marshal(os)
  os:marshalOctets(self.gameOrderId)
end
function CDelFailureOrderReq:unmarshal(os)
  self.gameOrderId = os:unmarshalOctets()
end
function CDelFailureOrderReq:sizepolicy(size)
  return size <= 65535
end
return CDelFailureOrderReq
