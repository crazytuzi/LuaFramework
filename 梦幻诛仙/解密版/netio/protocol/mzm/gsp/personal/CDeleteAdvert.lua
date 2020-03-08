local CDeleteAdvert = class("CDeleteAdvert")
CDeleteAdvert.TYPEID = 12603666
function CDeleteAdvert:ctor(advertType)
  self.id = 12603666
  self.advertType = advertType or nil
end
function CDeleteAdvert:marshal(os)
  os:marshalInt32(self.advertType)
end
function CDeleteAdvert:unmarshal(os)
  self.advertType = os:unmarshalInt32()
end
function CDeleteAdvert:sizepolicy(size)
  return size <= 65535
end
return CDeleteAdvert
