local SPetMarkUpgradeWithMarkSuccess = class("SPetMarkUpgradeWithMarkSuccess")
SPetMarkUpgradeWithMarkSuccess.TYPEID = 12628499
function SPetMarkUpgradeWithMarkSuccess:ctor(main_pet_mark_id, cost_pet_mark_id, now_level, now_exp, add_exp, new_pet_mark_info_map)
  self.id = 12628499
  self.main_pet_mark_id = main_pet_mark_id or nil
  self.cost_pet_mark_id = cost_pet_mark_id or nil
  self.now_level = now_level or nil
  self.now_exp = now_exp or nil
  self.add_exp = add_exp or nil
  self.new_pet_mark_info_map = new_pet_mark_info_map or {}
end
function SPetMarkUpgradeWithMarkSuccess:marshal(os)
  os:marshalInt64(self.main_pet_mark_id)
  os:marshalInt64(self.cost_pet_mark_id)
  os:marshalInt32(self.now_level)
  os:marshalInt32(self.now_exp)
  os:marshalInt32(self.add_exp)
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
function SPetMarkUpgradeWithMarkSuccess:unmarshal(os)
  self.main_pet_mark_id = os:unmarshalInt64()
  self.cost_pet_mark_id = os:unmarshalInt64()
  self.now_level = os:unmarshalInt32()
  self.now_exp = os:unmarshalInt32()
  self.add_exp = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local BeanClazz = require("netio.protocol.mzm.gsp.petmark.PetMarkInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.new_pet_mark_info_map[k] = v
  end
end
function SPetMarkUpgradeWithMarkSuccess:sizepolicy(size)
  return size <= 65535
end
return SPetMarkUpgradeWithMarkSuccess
