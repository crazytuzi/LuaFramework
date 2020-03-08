local SSynMarketItemBanTradeRes = class("SSynMarketItemBanTradeRes")
SSynMarketItemBanTradeRes.TYPEID = 12601457
function SSynMarketItemBanTradeRes:ctor(itemids)
  self.id = 12601457
  self.itemids = itemids or {}
end
function SSynMarketItemBanTradeRes:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.itemids) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, _ in pairs(self.itemids) do
    os:marshalInt32(k)
  end
end
function SSynMarketItemBanTradeRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.itemids[v] = v
  end
end
function SSynMarketItemBanTradeRes:sizepolicy(size)
  return size <= 65535
end
return SSynMarketItemBanTradeRes
