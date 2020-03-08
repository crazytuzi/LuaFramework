local SSynMarketPetBanTradeRes = class("SSynMarketPetBanTradeRes")
SSynMarketPetBanTradeRes.TYPEID = 12601458
function SSynMarketPetBanTradeRes:ctor(petCfgIds)
  self.id = 12601458
  self.petCfgIds = petCfgIds or {}
end
function SSynMarketPetBanTradeRes:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.petCfgIds) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, _ in pairs(self.petCfgIds) do
    os:marshalInt32(k)
  end
end
function SSynMarketPetBanTradeRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.petCfgIds[v] = v
  end
end
function SSynMarketPetBanTradeRes:sizepolicy(size)
  return size <= 65535
end
return SSynMarketPetBanTradeRes
