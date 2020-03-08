local CQueryPubOrSellNumberReq = class("CQueryPubOrSellNumberReq")
CQueryPubOrSellNumberReq.TYPEID = 12601441
function CQueryPubOrSellNumberReq:ctor(subids, pubOrsell)
  self.id = 12601441
  self.subids = subids or {}
  self.pubOrsell = pubOrsell or nil
end
function CQueryPubOrSellNumberReq:marshal(os)
  do
    local _size_ = 0
    for _, _ in pairs(self.subids) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, _ in pairs(self.subids) do
      os:marshalInt32(k)
    end
  end
  os:marshalInt32(self.pubOrsell)
end
function CQueryPubOrSellNumberReq:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.subids[v] = v
  end
  self.pubOrsell = os:unmarshalInt32()
end
function CQueryPubOrSellNumberReq:sizepolicy(size)
  return size <= 65535
end
return CQueryPubOrSellNumberReq
