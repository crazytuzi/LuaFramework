local CWuQIFuVigorSellReq = class("CWuQIFuVigorSellReq")
CWuQIFuVigorSellReq.TYPEID = 12584964
function CWuQIFuVigorSellReq:ctor(skillBagId, itemId, price, num)
  self.id = 12584964
  self.skillBagId = skillBagId or nil
  self.itemId = itemId or nil
  self.price = price or nil
  self.num = num or nil
end
function CWuQIFuVigorSellReq:marshal(os)
  os:marshalInt32(self.skillBagId)
  os:marshalInt32(self.itemId)
  os:marshalInt32(self.price)
  os:marshalInt32(self.num)
end
function CWuQIFuVigorSellReq:unmarshal(os)
  self.skillBagId = os:unmarshalInt32()
  self.itemId = os:unmarshalInt32()
  self.price = os:unmarshalInt32()
  self.num = os:unmarshalInt32()
end
function CWuQIFuVigorSellReq:sizepolicy(size)
  return size <= 65535
end
return CWuQIFuVigorSellReq
