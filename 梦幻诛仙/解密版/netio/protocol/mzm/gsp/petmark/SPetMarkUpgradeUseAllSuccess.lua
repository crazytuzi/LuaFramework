local SPetMarkUpgradeUseAllSuccess = class("SPetMarkUpgradeUseAllSuccess")
SPetMarkUpgradeUseAllSuccess.TYPEID = 12628507
function SPetMarkUpgradeUseAllSuccess:ctor(main_pet_mark_id, now_level, now_exp, add_exp, cost_pet_mark_ids, cost_item_map, new_pet_mark_info_map)
  self.id = 12628507
  self.main_pet_mark_id = main_pet_mark_id or nil
  self.now_level = now_level or nil
  self.now_exp = now_exp or nil
  self.add_exp = add_exp or nil
  self.cost_pet_mark_ids = cost_pet_mark_ids or {}
  self.cost_item_map = cost_item_map or {}
  self.new_pet_mark_info_map = new_pet_mark_info_map or {}
end
function SPetMarkUpgradeUseAllSuccess:marshal(os)
  os:marshalInt64(self.main_pet_mark_id)
  os:marshalInt32(self.now_level)
  os:marshalInt32(self.now_exp)
  os:marshalInt32(self.add_exp)
  os:marshalCompactUInt32(table.getn(self.cost_pet_mark_ids))
  for _, v in ipairs(self.cost_pet_mark_ids) do
    os:marshalInt64(v)
  end
  do
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
  local _size_ = 0
  for _, _ in pairs(self.new_pet_mark_info_map) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.new_pet_mark_info_map) do
    os:marshalInt64(k)
    v:marshal(os)
  end
end
function SPetMarkUpgradeUseAllSuccess:unmarshal(os)
  self.main_pet_mark_id = os:unmarshalInt64()
  self.now_level = os:unmarshalInt32()
  self.now_exp = os:unmarshalInt32()
  self.add_exp = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.cost_pet_mark_ids, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.cost_item_map[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local BeanClazz = require("netio.protocol.mzm.gsp.petmark.PetMarkInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.new_pet_mark_info_map[k] = v
  end
end
function SPetMarkUpgradeUseAllSuccess:sizepolicy(size)
  return size <= 65535
end
return SPetMarkUpgradeUseAllSuccess
