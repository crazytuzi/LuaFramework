local SSyncGrcGiftTypeOnOff = class("SSyncGrcGiftTypeOnOff")
SSyncGrcGiftTypeOnOff.TYPEID = 12600321
function SSyncGrcGiftTypeOnOff:ctor(gift_type_onoff_map)
  self.id = 12600321
  self.gift_type_onoff_map = gift_type_onoff_map or {}
end
function SSyncGrcGiftTypeOnOff:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.gift_type_onoff_map) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.gift_type_onoff_map) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SSyncGrcGiftTypeOnOff:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.gift_type_onoff_map[k] = v
  end
end
function SSyncGrcGiftTypeOnOff:sizepolicy(size)
  return size <= 65535
end
return SSyncGrcGiftTypeOnOff
