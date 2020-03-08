local CGrcSendGift = class("CGrcSendGift")
CGrcSendGift.TYPEID = 12600338
function CGrcSendGift:ctor(gift_type, to)
  self.id = 12600338
  self.gift_type = gift_type or nil
  self.to = to or nil
end
function CGrcSendGift:marshal(os)
  os:marshalInt32(self.gift_type)
  os:marshalOctets(self.to)
end
function CGrcSendGift:unmarshal(os)
  self.gift_type = os:unmarshalInt32()
  self.to = os:unmarshalOctets()
end
function CGrcSendGift:sizepolicy(size)
  return size <= 65535
end
return CGrcSendGift
