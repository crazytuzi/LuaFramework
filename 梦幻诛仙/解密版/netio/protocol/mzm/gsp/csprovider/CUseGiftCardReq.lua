local CUseGiftCardReq = class("CUseGiftCardReq")
CUseGiftCardReq.TYPEID = 12589317
function CUseGiftCardReq:ctor(cardNumber)
  self.id = 12589317
  self.cardNumber = cardNumber or nil
end
function CUseGiftCardReq:marshal(os)
  os:marshalString(self.cardNumber)
end
function CUseGiftCardReq:unmarshal(os)
  self.cardNumber = os:unmarshalString()
end
function CUseGiftCardReq:sizepolicy(size)
  return size <= 65535
end
return CUseGiftCardReq
