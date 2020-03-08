local SEquipRes = class("SEquipRes")
SEquipRes.TYPEID = 12584835
function SEquipRes:ctor(uuids, super_equipment_uuids)
  self.id = 12584835
  self.uuids = uuids or {}
  self.super_equipment_uuids = super_equipment_uuids or {}
end
function SEquipRes:marshal(os)
  do
    local _size_ = 0
    for _, _ in pairs(self.uuids) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, _ in pairs(self.uuids) do
      os:marshalInt64(k)
    end
  end
  local _size_ = 0
  for _, _ in pairs(self.super_equipment_uuids) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, _ in pairs(self.super_equipment_uuids) do
    os:marshalInt64(k)
  end
end
function SEquipRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    self.uuids[v] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    self.super_equipment_uuids[v] = v
  end
end
function SEquipRes:sizepolicy(size)
  return size <= 65535
end
return SEquipRes
