local SAllCustomizedConditionsRes = class("SAllCustomizedConditionsRes")
SAllCustomizedConditionsRes.TYPEID = 12601443
function SAllCustomizedConditionsRes:ctor(subid2EquipCons, subid2PetEquipCons, subid2PetCons)
  self.id = 12601443
  self.subid2EquipCons = subid2EquipCons or {}
  self.subid2PetEquipCons = subid2PetEquipCons or {}
  self.subid2PetCons = subid2PetCons or {}
end
function SAllCustomizedConditionsRes:marshal(os)
  do
    local _size_ = 0
    for _, _ in pairs(self.subid2EquipCons) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.subid2EquipCons) do
      os:marshalInt32(k)
      v:marshal(os)
    end
  end
  do
    local _size_ = 0
    for _, _ in pairs(self.subid2PetEquipCons) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.subid2PetEquipCons) do
      os:marshalInt32(k)
      v:marshal(os)
    end
  end
  local _size_ = 0
  for _, _ in pairs(self.subid2PetCons) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.subid2PetCons) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function SAllCustomizedConditionsRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.market.EquipConditions")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.subid2EquipCons[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.market.PetEquipConditions")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.subid2PetEquipCons[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.market.PetConditions")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.subid2PetCons[k] = v
  end
end
function SAllCustomizedConditionsRes:sizepolicy(size)
  return size <= 65535
end
return SAllCustomizedConditionsRes
