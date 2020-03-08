local SSynGrapPositionRes = class("SSynGrapPositionRes")
SSynGrapPositionRes.TYPEID = 12621584
function SSynGrapPositionRes:ctor(position2firstBlood)
  self.id = 12621584
  self.position2firstBlood = position2firstBlood or {}
end
function SSynGrapPositionRes:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.position2firstBlood) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.position2firstBlood) do
    os:marshalInt32(k)
    os:marshalInt64(v)
  end
end
function SSynGrapPositionRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt64()
    self.position2firstBlood[k] = v
  end
end
function SSynGrapPositionRes:sizepolicy(size)
  return size <= 65535
end
return SSynGrapPositionRes
