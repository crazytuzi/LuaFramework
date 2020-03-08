local SQueryItemPricRes = class("SQueryItemPricRes")
SQueryItemPricRes.TYPEID = 12601404
function SQueryItemPricRes:ctor(itemId, prices)
  self.id = 12601404
  self.itemId = itemId or nil
  self.prices = prices or {}
end
function SQueryItemPricRes:marshal(os)
  os:marshalInt32(self.itemId)
  os:marshalCompactUInt32(table.getn(self.prices))
  for _, v in ipairs(self.prices) do
    os:marshalInt32(v)
  end
end
function SQueryItemPricRes:unmarshal(os)
  self.itemId = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.prices, v)
  end
end
function SQueryItemPricRes:sizepolicy(size)
  return size <= 65535
end
return SQueryItemPricRes
