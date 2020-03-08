local SBuyItemRes = class("SBuyItemRes")
SBuyItemRes.TYPEID = 12585481
function SBuyItemRes:ctor(malltype, itemid, buynum)
  self.id = 12585481
  self.malltype = malltype or nil
  self.itemid = itemid or nil
  self.buynum = buynum or nil
end
function SBuyItemRes:marshal(os)
  os:marshalInt32(self.malltype)
  os:marshalInt32(self.itemid)
  os:marshalInt32(self.buynum)
end
function SBuyItemRes:unmarshal(os)
  self.malltype = os:unmarshalInt32()
  self.itemid = os:unmarshalInt32()
  self.buynum = os:unmarshalInt32()
end
function SBuyItemRes:sizepolicy(size)
  return size <= 65535
end
return SBuyItemRes
