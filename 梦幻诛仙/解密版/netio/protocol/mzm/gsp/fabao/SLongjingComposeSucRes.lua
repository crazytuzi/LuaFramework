local SLongjingComposeSucRes = class("SLongjingComposeSucRes")
SLongjingComposeSucRes.TYPEID = 12596029
function SLongjingComposeSucRes:ctor(itemid2Num)
  self.id = 12596029
  self.itemid2Num = itemid2Num or {}
end
function SLongjingComposeSucRes:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.itemid2Num) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.itemid2Num) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SLongjingComposeSucRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.itemid2Num[k] = v
  end
end
function SLongjingComposeSucRes:sizepolicy(size)
  return size <= 65535
end
return SLongjingComposeSucRes
