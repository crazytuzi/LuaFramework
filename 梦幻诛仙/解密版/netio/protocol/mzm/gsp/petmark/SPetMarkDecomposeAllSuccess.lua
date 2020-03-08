local SPetMarkDecomposeAllSuccess = class("SPetMarkDecomposeAllSuccess")
SPetMarkDecomposeAllSuccess.TYPEID = 12628500
function SPetMarkDecomposeAllSuccess:ctor(get_score_map, cost_pet_mark_ids, cost_item_map)
  self.id = 12628500
  self.get_score_map = get_score_map or {}
  self.cost_pet_mark_ids = cost_pet_mark_ids or {}
  self.cost_item_map = cost_item_map or {}
end
function SPetMarkDecomposeAllSuccess:marshal(os)
  do
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
  os:marshalCompactUInt32(table.getn(self.cost_pet_mark_ids))
  for _, v in ipairs(self.cost_pet_mark_ids) do
    os:marshalInt64(v)
  end
  local _size_ = 0
  for _, _ in pairs(self.cost_item_map) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.cost_item_map) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SPetMarkDecomposeAllSuccess:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.get_score_map[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.cost_pet_mark_ids, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.cost_item_map[k] = v
  end
end
function SPetMarkDecomposeAllSuccess:sizepolicy(size)
  return size <= 65535
end
return SPetMarkDecomposeAllSuccess
