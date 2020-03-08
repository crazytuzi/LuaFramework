local SQueryPubOrSellNumberRes = class("SQueryPubOrSellNumberRes")
SQueryPubOrSellNumberRes.TYPEID = 12601442
function SQueryPubOrSellNumberRes:ctor(subid2num, pubOrsell)
  self.id = 12601442
  self.subid2num = subid2num or {}
  self.pubOrsell = pubOrsell or nil
end
function SQueryPubOrSellNumberRes:marshal(os)
  do
    local _size_ = 0
    for _, _ in pairs(self.subid2num) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.subid2num) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  os:marshalInt32(self.pubOrsell)
end
function SQueryPubOrSellNumberRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.subid2num[k] = v
  end
  self.pubOrsell = os:unmarshalInt32()
end
function SQueryPubOrSellNumberRes:sizepolicy(size)
  return size <= 65535
end
return SQueryPubOrSellNumberRes
