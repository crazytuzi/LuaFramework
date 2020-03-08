local SGetAwardSuccess = class("SGetAwardSuccess")
SGetAwardSuccess.TYPEID = 12605697
function SGetAwardSuccess:ctor(item2num)
  self.id = 12605697
  self.item2num = item2num or {}
end
function SGetAwardSuccess:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.item2num) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.item2num) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SGetAwardSuccess:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.item2num[k] = v
  end
end
function SGetAwardSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetAwardSuccess
