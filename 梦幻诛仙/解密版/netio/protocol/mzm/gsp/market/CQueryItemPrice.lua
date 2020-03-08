local CQueryItemPrice = class("CQueryItemPrice")
CQueryItemPrice.TYPEID = 12601403
function CQueryItemPrice:ctor(itemId)
  self.id = 12601403
  self.itemId = itemId or nil
end
function CQueryItemPrice:marshal(os)
  os:marshalInt32(self.itemId)
end
function CQueryItemPrice:unmarshal(os)
  self.itemId = os:unmarshalInt32()
end
function CQueryItemPrice:sizepolicy(size)
  return size <= 65535
end
return CQueryItemPrice
