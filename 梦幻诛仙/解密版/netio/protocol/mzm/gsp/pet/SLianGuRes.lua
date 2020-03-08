local SLianGuRes = class("SLianGuRes")
SLianGuRes.TYPEID = 12590605
function SLianGuRes:ctor(petId, aptMap, lianguItemLeft)
  self.id = 12590605
  self.petId = petId or nil
  self.aptMap = aptMap or {}
  self.lianguItemLeft = lianguItemLeft or nil
end
function SLianGuRes:marshal(os)
  os:marshalInt64(self.petId)
  do
    local _size_ = 0
    for _, _ in pairs(self.aptMap) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.aptMap) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  os:marshalInt32(self.lianguItemLeft)
end
function SLianGuRes:unmarshal(os)
  self.petId = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.aptMap[k] = v
  end
  self.lianguItemLeft = os:unmarshalInt32()
end
function SLianGuRes:sizepolicy(size)
  return size <= 65535
end
return SLianGuRes
