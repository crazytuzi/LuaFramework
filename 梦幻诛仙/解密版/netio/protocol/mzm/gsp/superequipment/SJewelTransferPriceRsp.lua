local SJewelTransferPriceRsp = class("SJewelTransferPriceRsp")
SJewelTransferPriceRsp.TYPEID = 12618782
function SJewelTransferPriceRsp:ctor(jewelCfgId2price)
  self.id = 12618782
  self.jewelCfgId2price = jewelCfgId2price or {}
end
function SJewelTransferPriceRsp:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.jewelCfgId2price) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.jewelCfgId2price) do
    os:marshalInt32(k)
    os:marshalFloat(v)
  end
end
function SJewelTransferPriceRsp:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalFloat()
    self.jewelCfgId2price[k] = v
  end
end
function SJewelTransferPriceRsp:sizepolicy(size)
  return size <= 65535
end
return SJewelTransferPriceRsp
