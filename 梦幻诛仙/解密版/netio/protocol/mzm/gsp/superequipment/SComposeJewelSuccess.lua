local SComposeJewelSuccess = class("SComposeJewelSuccess")
SComposeJewelSuccess.TYPEID = 12618765
function SComposeJewelSuccess:ctor(jewelCfgId2count)
  self.id = 12618765
  self.jewelCfgId2count = jewelCfgId2count or {}
end
function SComposeJewelSuccess:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.jewelCfgId2count) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.jewelCfgId2count) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SComposeJewelSuccess:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.jewelCfgId2count[k] = v
  end
end
function SComposeJewelSuccess:sizepolicy(size)
  return size <= 65535
end
return SComposeJewelSuccess
