local CUseActivateCardReq = class("CUseActivateCardReq")
CUseActivateCardReq.TYPEID = 12589319
function CUseActivateCardReq:ctor(cardNumber)
  self.id = 12589319
  self.cardNumber = cardNumber or nil
end
function CUseActivateCardReq:marshal(os)
  os:marshalString(self.cardNumber)
end
function CUseActivateCardReq:unmarshal(os)
  self.cardNumber = os:unmarshalString()
end
function CUseActivateCardReq:sizepolicy(size)
  return size <= 1024
end
return CUseActivateCardReq
