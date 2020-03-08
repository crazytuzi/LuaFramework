local ModelInfo = require("netio.protocol.mzm.gsp.pubdata.ModelInfo")
local AircraftDataInfo = require("netio.protocol.mzm.gsp.aircraft.AircraftDataInfo")
local SQueryRoleEquipInfoRes = class("SQueryRoleEquipInfoRes")
SQueryRoleEquipInfoRes.TYPEID = 12584832
function SQueryRoleEquipInfoRes:ctor(roleid, rolename, ocpid, level, items, modelinfo, winginfos, fabaoInfos, aircraft)
  self.id = 12584832
  self.roleid = roleid or nil
  self.rolename = rolename or nil
  self.ocpid = ocpid or nil
  self.level = level or nil
  self.items = items or {}
  self.modelinfo = modelinfo or ModelInfo.new()
  self.winginfos = winginfos or {}
  self.fabaoInfos = fabaoInfos or {}
  self.aircraft = aircraft or AircraftDataInfo.new()
end
function SQueryRoleEquipInfoRes:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalString(self.rolename)
  os:marshalInt32(self.ocpid)
  os:marshalInt32(self.level)
  do
    local _size_ = 0
    for _, _ in pairs(self.items) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.items) do
      os:marshalInt32(k)
      v:marshal(os)
    end
  end
  self.modelinfo:marshal(os)
  os:marshalCompactUInt32(table.getn(self.winginfos))
  for _, v in ipairs(self.winginfos) do
    v:marshal(os)
  end
  os:marshalCompactUInt32(table.getn(self.fabaoInfos))
  for _, v in ipairs(self.fabaoInfos) do
    v:marshal(os)
  end
  self.aircraft:marshal(os)
end
function SQueryRoleEquipInfoRes:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.rolename = os:unmarshalString()
  self.ocpid = os:unmarshalInt32()
  self.level = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.item.ItemInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.items[k] = v
  end
  self.modelinfo = ModelInfo.new()
  self.modelinfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.wing.WingSimpleData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.winginfos, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.item.ItemInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.fabaoInfos, v)
  end
  self.aircraft = AircraftDataInfo.new()
  self.aircraft:unmarshal(os)
end
function SQueryRoleEquipInfoRes:sizepolicy(size)
  return size <= 65535
end
return SQueryRoleEquipInfoRes
