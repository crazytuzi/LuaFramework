local SSynCountDownInfo = class("SSynCountDownInfo")
SSynCountDownInfo.TYPEID = 12606724
function SSynCountDownInfo:ctor(not_get_red_packet_cfg_ids)
  self.id = 12606724
  self.not_get_red_packet_cfg_ids = not_get_red_packet_cfg_ids or {}
end
function SSynCountDownInfo:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.not_get_red_packet_cfg_ids) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, _ in pairs(self.not_get_red_packet_cfg_ids) do
    os:marshalInt32(k)
  end
end
function SSynCountDownInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.not_get_red_packet_cfg_ids[v] = v
  end
end
function SSynCountDownInfo:sizepolicy(size)
  return size <= 65535
end
return SSynCountDownInfo
