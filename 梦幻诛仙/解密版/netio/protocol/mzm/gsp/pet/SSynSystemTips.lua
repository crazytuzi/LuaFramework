local SSynSystemTips = class("SSynSystemTips")
SSynSystemTips.TYPEID = 12590639
SSynSystemTips.TILI_APT = 0
SSynSystemTips.MAG_APT = 1
SSynSystemTips.ATK_APT = 2
SSynSystemTips.DEF_APT = 3
SSynSystemTips.SPEED_APT = 4
function SSynSystemTips:ctor(extraMap)
  self.id = 12590639
  self.extraMap = extraMap or {}
end
function SSynSystemTips:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.extraMap) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.extraMap) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SSynSystemTips:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.extraMap[k] = v
  end
end
function SSynSystemTips:sizepolicy(size)
  return size <= 65535
end
return SSynSystemTips
