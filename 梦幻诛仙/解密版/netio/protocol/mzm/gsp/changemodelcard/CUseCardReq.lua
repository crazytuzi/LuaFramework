local CUseCardReq = class("CUseCardReq")
CUseCardReq.TYPEID = 12624415
function CUseCardReq:ctor(card_id)
  self.id = 12624415
  self.card_id = card_id or nil
end
function CUseCardReq:marshal(os)
  os:marshalInt64(self.card_id)
end
function CUseCardReq:unmarshal(os)
  self.card_id = os:unmarshalInt64()
end
function CUseCardReq:sizepolicy(size)
  return size <= 65535
end
return CUseCardReq
