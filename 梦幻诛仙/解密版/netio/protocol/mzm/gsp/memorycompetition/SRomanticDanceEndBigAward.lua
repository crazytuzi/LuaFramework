local SRomanticDanceEndBigAward = class("SRomanticDanceEndBigAward")
SRomanticDanceEndBigAward.TYPEID = 12613121
function SRomanticDanceEndBigAward:ctor(award_item_map)
  self.id = 12613121
  self.award_item_map = award_item_map or {}
end
function SRomanticDanceEndBigAward:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.award_item_map) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.award_item_map) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SRomanticDanceEndBigAward:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.award_item_map[k] = v
  end
end
function SRomanticDanceEndBigAward:sizepolicy(size)
  return size <= 65535
end
return SRomanticDanceEndBigAward
