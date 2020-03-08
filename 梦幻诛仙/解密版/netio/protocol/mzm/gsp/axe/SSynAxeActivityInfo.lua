local SSynAxeActivityInfo = class("SSynAxeActivityInfo")
SSynAxeActivityInfo.TYPEID = 12614918
function SSynAxeActivityInfo:ctor(activity_infos)
  self.id = 12614918
  self.activity_infos = activity_infos or {}
end
function SSynAxeActivityInfo:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.activity_infos) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.activity_infos) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SSynAxeActivityInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.activity_infos[k] = v
  end
end
function SSynAxeActivityInfo:sizepolicy(size)
  return size <= 65535
end
return SSynAxeActivityInfo
