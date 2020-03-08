local SBreedBabyChildEnd = class("SBreedBabyChildEnd")
SBreedBabyChildEnd.TYPEID = 12609311
function SBreedBabyChildEnd:ctor(child_id, operator, now_baby_property)
  self.id = 12609311
  self.child_id = child_id or nil
  self.operator = operator or nil
  self.now_baby_property = now_baby_property or {}
end
function SBreedBabyChildEnd:marshal(os)
  os:marshalInt64(self.child_id)
  os:marshalInt32(self.operator)
  local _size_ = 0
  for _, _ in pairs(self.now_baby_property) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.now_baby_property) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SBreedBabyChildEnd:unmarshal(os)
  self.child_id = os:unmarshalInt64()
  self.operator = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.now_baby_property[k] = v
  end
end
function SBreedBabyChildEnd:sizepolicy(size)
  return size <= 65535
end
return SBreedBabyChildEnd
