local SChineseValentineRound = class("SChineseValentineRound")
SChineseValentineRound.TYPEID = 12622090
function SChineseValentineRound:ctor(roundNumber, highLightMap)
  self.id = 12622090
  self.roundNumber = roundNumber or nil
  self.highLightMap = highLightMap or {}
end
function SChineseValentineRound:marshal(os)
  os:marshalInt32(self.roundNumber)
  local _size_ = 0
  for _, _ in pairs(self.highLightMap) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.highLightMap) do
    os:marshalInt64(k)
    os:marshalInt32(v)
  end
end
function SChineseValentineRound:unmarshal(os)
  self.roundNumber = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local v = os:unmarshalInt32()
    self.highLightMap[k] = v
  end
end
function SChineseValentineRound:sizepolicy(size)
  return size <= 65535
end
return SChineseValentineRound
