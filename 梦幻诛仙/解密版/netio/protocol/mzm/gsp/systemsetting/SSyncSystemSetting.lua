local SSyncSystemSetting = class("SSyncSystemSetting")
SSyncSystemSetting.TYPEID = 12587266
function SSyncSystemSetting:ctor(settingMap)
  self.id = 12587266
  self.settingMap = settingMap or {}
end
function SSyncSystemSetting:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.settingMap) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.settingMap) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SSyncSystemSetting:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.settingMap[k] = v
  end
end
function SSyncSystemSetting:sizepolicy(size)
  return size <= 65535
end
return SSyncSystemSetting
