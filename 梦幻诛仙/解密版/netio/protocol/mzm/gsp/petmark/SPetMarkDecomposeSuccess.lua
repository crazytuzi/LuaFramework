local SPetMarkDecomposeSuccess = class("SPetMarkDecomposeSuccess")
SPetMarkDecomposeSuccess.TYPEID = 12628481
function SPetMarkDecomposeSuccess:ctor(pet_mark_id, get_score_map)
  self.id = 12628481
  self.pet_mark_id = pet_mark_id or nil
  self.get_score_map = get_score_map or {}
end
function SPetMarkDecomposeSuccess:marshal(os)
  os:marshalInt64(self.pet_mark_id)
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
function SPetMarkDecomposeSuccess:unmarshal(os)
  self.pet_mark_id = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.get_score_map[k] = v
  end
end
function SPetMarkDecomposeSuccess:sizepolicy(size)
  return size <= 65535
end
return SPetMarkDecomposeSuccess
