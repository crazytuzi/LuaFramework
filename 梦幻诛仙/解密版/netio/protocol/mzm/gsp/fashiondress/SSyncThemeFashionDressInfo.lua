local SSyncThemeFashionDressInfo = class("SSyncThemeFashionDressInfo")
SSyncThemeFashionDressInfo.TYPEID = 12603159
function SSyncThemeFashionDressInfo:ctor(unlock_theme_fashion_dress_type_id_set)
  self.id = 12603159
  self.unlock_theme_fashion_dress_type_id_set = unlock_theme_fashion_dress_type_id_set or {}
end
function SSyncThemeFashionDressInfo:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.unlock_theme_fashion_dress_type_id_set) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, _ in pairs(self.unlock_theme_fashion_dress_type_id_set) do
    os:marshalInt32(k)
  end
end
function SSyncThemeFashionDressInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.unlock_theme_fashion_dress_type_id_set[v] = v
  end
end
function SSyncThemeFashionDressInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncThemeFashionDressInfo
