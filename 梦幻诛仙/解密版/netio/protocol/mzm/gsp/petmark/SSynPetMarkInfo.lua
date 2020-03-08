local SSynPetMarkInfo = class("SSynPetMarkInfo")
SSynPetMarkInfo.TYPEID = 12628503
function SSynPetMarkInfo:ctor(pet_mark_info_map, pet_mark_equip_map)
  self.id = 12628503
  self.pet_mark_info_map = pet_mark_info_map or {}
  self.pet_mark_equip_map = pet_mark_equip_map or {}
end
function SSynPetMarkInfo:marshal(os)
  do
    local _size_ = 0
    for _, _ in pairs(self.pet_mark_info_map) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.pet_mark_info_map) do
      os:marshalInt64(k)
      v:marshal(os)
    end
  end
  local _size_ = 0
  for _, _ in pairs(self.pet_mark_equip_map) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.pet_mark_equip_map) do
    os:marshalInt64(k)
    os:marshalInt64(v)
  end
end
function SSynPetMarkInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local BeanClazz = require("netio.protocol.mzm.gsp.petmark.PetMarkInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.pet_mark_info_map[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local v = os:unmarshalInt64()
    self.pet_mark_equip_map[k] = v
  end
end
function SSynPetMarkInfo:sizepolicy(size)
  return size <= 65535
end
return SSynPetMarkInfo
