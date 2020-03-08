local OctetsStream = require("netio.OctetsStream")
local SuperEquipmentCostInfo = require("netio.protocol.mzm.gsp.item.SuperEquipmentCostInfo")
local ItemInfo = class("ItemInfo")
ItemInfo.BIND = 1
function ItemInfo:ctor(id, number, flag, extraMap, exproList, extraProps, uuid, fumoProList, extraInfoMap, super_equipment_cost_bean, jewelMap)
  self.id = id or nil
  self.number = number or nil
  self.flag = flag or nil
  self.extraMap = extraMap or {}
  self.exproList = exproList or {}
  self.extraProps = extraProps or {}
  self.uuid = uuid or {}
  self.fumoProList = fumoProList or {}
  self.extraInfoMap = extraInfoMap or {}
  self.super_equipment_cost_bean = super_equipment_cost_bean or SuperEquipmentCostInfo.new()
  self.jewelMap = jewelMap or {}
end
function ItemInfo:marshal(os)
  os:marshalInt32(self.id)
  os:marshalInt32(self.number)
  os:marshalInt32(self.flag)
  do
    local _size_ = 0
    for _, _ in pairs(self.extraMap) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.extraMap) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  os:marshalCompactUInt32(table.getn(self.exproList))
  for _, v in ipairs(self.exproList) do
    v:marshal(os)
  end
  do
    local _size_ = 0
    for _, _ in pairs(self.extraProps) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.extraProps) do
      os:marshalInt32(k)
      v:marshal(os)
    end
  end
  os:marshalCompactUInt32(table.getn(self.uuid))
  for _, v in ipairs(self.uuid) do
    os:marshalInt64(v)
  end
  os:marshalCompactUInt32(table.getn(self.fumoProList))
  for _, v in ipairs(self.fumoProList) do
    v:marshal(os)
  end
  do
    local _size_ = 0
    for _, _ in pairs(self.extraInfoMap) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.extraInfoMap) do
      os:marshalInt32(k)
      os:marshalInt64(v)
    end
  end
  self.super_equipment_cost_bean:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.jewelMap) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.jewelMap) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function ItemInfo:unmarshal(os)
  self.id = os:unmarshalInt32()
  self.number = os:unmarshalInt32()
  self.flag = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.extraMap[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.item.ExtraProBean")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.exproList, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.item.TempExtraProInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.extraProps[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.uuid, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.item.FumoInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.fumoProList, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt64()
    self.extraInfoMap[k] = v
  end
  self.super_equipment_cost_bean = SuperEquipmentCostInfo.new()
  self.super_equipment_cost_bean:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.item.JewelInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.jewelMap[k] = v
  end
end
return ItemInfo
