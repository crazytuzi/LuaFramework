local SSyncCareActivity = class("SSyncCareActivity")
SSyncCareActivity.TYPEID = 12587566
function SSyncCareActivity:ctor(careMap)
  self.id = 12587566
  self.careMap = careMap or {}
end
function SSyncCareActivity:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.careMap) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.careMap) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SSyncCareActivity:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.careMap[k] = v
  end
end
function SSyncCareActivity:sizepolicy(size)
  return size <= 65535
end
return SSyncCareActivity
