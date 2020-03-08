local SPetMarkItemDecomposeSuccess = class("SPetMarkItemDecomposeSuccess")
SPetMarkItemDecomposeSuccess.TYPEID = 12628489
function SPetMarkItemDecomposeSuccess:ctor(get_score_map)
  self.id = 12628489
  self.get_score_map = get_score_map or {}
end
function SPetMarkItemDecomposeSuccess:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.get_score_map) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.get_score_map) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SPetMarkItemDecomposeSuccess:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.get_score_map[k] = v
  end
end
function SPetMarkItemDecomposeSuccess:sizepolicy(size)
  return size <= 65535
end
return SPetMarkItemDecomposeSuccess
