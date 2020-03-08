local SSyncThemeFashionDressUpdateInfo = class("SSyncThemeFashionDressUpdateInfo")
SSyncThemeFashionDressUpdateInfo.TYPEID = 12603158
function SSyncThemeFashionDressUpdateInfo:ctor(add_set, delete_set)
  self.id = 12603158
  self.add_set = add_set or {}
  self.delete_set = delete_set or {}
end
function SSyncThemeFashionDressUpdateInfo:marshal(os)
  do
    local _size_ = 0
    for _, _ in pairs(self.add_set) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, _ in pairs(self.add_set) do
      os:marshalInt32(k)
    end
  end
  local _size_ = 0
  for _, _ in pairs(self.delete_set) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, _ in pairs(self.delete_set) do
    os:marshalInt32(k)
  end
end
function SSyncThemeFashionDressUpdateInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.add_set[v] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.delete_set[v] = v
  end
end
function SSyncThemeFashionDressUpdateInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncThemeFashionDressUpdateInfo
