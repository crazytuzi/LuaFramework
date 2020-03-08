local SQueryLongjingTransferPriceRes = class("SQueryLongjingTransferPriceRes")
SQueryLongjingTransferPriceRes.TYPEID = 12596039
function SQueryLongjingTransferPriceRes:ctor(itemid2price)
  self.id = 12596039
  self.itemid2price = itemid2price or {}
end
function SQueryLongjingTransferPriceRes:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.itemid2price) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.itemid2price) do
    os:marshalInt32(k)
    os:marshalFloat(v)
  end
end
function SQueryLongjingTransferPriceRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalFloat()
    self.itemid2price[k] = v
  end
end
function SQueryLongjingTransferPriceRes:sizepolicy(size)
  return size <= 65535
end
return SQueryLongjingTransferPriceRes
