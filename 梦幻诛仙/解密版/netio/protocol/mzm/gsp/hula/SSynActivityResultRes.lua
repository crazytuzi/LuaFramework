local SSynActivityResultRes = class("SSynActivityResultRes")
SSynActivityResultRes.TYPEID = 12608781
function SSynActivityResultRes:ctor(point, delete_monsterid_2_count, delete_type_2_count, kill_monsterid_2_count)
  self.id = 12608781
  self.point = point or nil
  self.delete_monsterid_2_count = delete_monsterid_2_count or {}
  self.delete_type_2_count = delete_type_2_count or {}
  self.kill_monsterid_2_count = kill_monsterid_2_count or {}
end
function SSynActivityResultRes:marshal(os)
  os:marshalInt32(self.point)
  do
    local _size_ = 0
    for _, _ in pairs(self.delete_monsterid_2_count) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.delete_monsterid_2_count) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  do
    local _size_ = 0
    for _, _ in pairs(self.delete_type_2_count) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.delete_type_2_count) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  local _size_ = 0
  for _, _ in pairs(self.kill_monsterid_2_count) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.kill_monsterid_2_count) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SSynActivityResultRes:unmarshal(os)
  self.point = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.delete_monsterid_2_count[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.delete_type_2_count[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.kill_monsterid_2_count[k] = v
  end
end
function SSynActivityResultRes:sizepolicy(size)
  return size <= 65535
end
return SSynActivityResultRes
