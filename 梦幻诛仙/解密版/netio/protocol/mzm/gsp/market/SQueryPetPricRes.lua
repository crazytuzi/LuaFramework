local SQueryPetPricRes = class("SQueryPetPricRes")
SQueryPetPricRes.TYPEID = 12601402
function SQueryPetPricRes:ctor(petCfgId, prices)
  self.id = 12601402
  self.petCfgId = petCfgId or nil
  self.prices = prices or {}
end
function SQueryPetPricRes:marshal(os)
  os:marshalInt32(self.petCfgId)
  os:marshalCompactUInt32(table.getn(self.prices))
  for _, v in ipairs(self.prices) do
    os:marshalInt32(v)
  end
end
function SQueryPetPricRes:unmarshal(os)
  self.petCfgId = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.prices, v)
  end
end
function SQueryPetPricRes:sizepolicy(size)
  return size <= 65535
end
return SQueryPetPricRes
