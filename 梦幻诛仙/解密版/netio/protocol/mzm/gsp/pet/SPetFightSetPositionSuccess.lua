local SPetFightSetPositionSuccess = class("SPetFightSetPositionSuccess")
SPetFightSetPositionSuccess.TYPEID = 12590691
function SPetFightSetPositionSuccess:ctor(team, position2pet)
  self.id = 12590691
  self.team = team or nil
  self.position2pet = position2pet or {}
end
function SPetFightSetPositionSuccess:marshal(os)
  os:marshalInt32(self.team)
  local _size_ = 0
  for _, _ in pairs(self.position2pet) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.position2pet) do
    os:marshalInt32(k)
    os:marshalInt64(v)
  end
end
function SPetFightSetPositionSuccess:unmarshal(os)
  self.team = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt64()
    self.position2pet[k] = v
  end
end
function SPetFightSetPositionSuccess:sizepolicy(size)
  return size <= 65535
end
return SPetFightSetPositionSuccess
