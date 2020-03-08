local SGetSellItemRes = class("SGetSellItemRes")
SGetSellItemRes.TYPEID = 12584977
function SGetSellItemRes:ctor(shoppingid)
  self.id = 12584977
  self.shoppingid = shoppingid or nil
end
function SGetSellItemRes:marshal(os)
  os:marshalInt64(self.shoppingid)
end
function SGetSellItemRes:unmarshal(os)
  self.shoppingid = os:unmarshalInt64()
end
function SGetSellItemRes:sizepolicy(size)
  return size <= 65535
end
return SGetSellItemRes
