local CJewelTransferPriceReq = class("CJewelTransferPriceReq")
CJewelTransferPriceReq.TYPEID = 12618787
function CJewelTransferPriceReq:ctor(jewelCfgIds)
  self.id = 12618787
  self.jewelCfgIds = jewelCfgIds or {}
end
function CJewelTransferPriceReq:marshal(os)
  os:marshalCompactUInt32(table.getn(self.jewelCfgIds))
  for _, v in ipairs(self.jewelCfgIds) do
    os:marshalInt32(v)
  end
end
function CJewelTransferPriceReq:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.jewelCfgIds, v)
  end
end
function CJewelTransferPriceReq:sizepolicy(size)
  return size <= 65535
end
return CJewelTransferPriceReq
