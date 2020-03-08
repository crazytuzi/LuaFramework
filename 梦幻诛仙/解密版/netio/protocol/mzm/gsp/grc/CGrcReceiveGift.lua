local CGrcReceiveGift = class("CGrcReceiveGift")
CGrcReceiveGift.TYPEID = 12600341
function CGrcReceiveGift:ctor(gift_type, serialid)
  self.id = 12600341
  self.gift_type = gift_type or nil
  self.serialid = serialid or nil
end
function CGrcReceiveGift:marshal(os)
  os:marshalInt32(self.gift_type)
  os:marshalInt64(self.serialid)
end
function CGrcReceiveGift:unmarshal(os)
  self.gift_type = os:unmarshalInt32()
  self.serialid = os:unmarshalInt64()
end
function CGrcReceiveGift:sizepolicy(size)
  return size <= 65535
end
return CGrcReceiveGift
