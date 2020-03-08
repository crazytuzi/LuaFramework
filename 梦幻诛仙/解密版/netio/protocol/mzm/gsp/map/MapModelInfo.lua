local OctetsStream = require("netio.OctetsStream")
local ModelInfo = require("netio.protocol.mzm.gsp.pubdata.ModelInfo")
local MapModelInfo = class("MapModelInfo")
MapModelInfo.TITLEID = 0
MapModelInfo.APPELLATIONID = 1
MapModelInfo.HUSONG_FOLLOW_MONSTER_ID = 4
MapModelInfo.MAP_APP_COLOR_ID = 5
MapModelInfo.HUSONG_COUPLE_FLY_NPC_CFG_ID = 6
MapModelInfo.GENDER = 7
MapModelInfo.NAME = 0
MapModelInfo.APPELLATION = 1
MapModelInfo.MAP_APP_TEXT = 2
function MapModelInfo:ctor(id, model, velocity, role_status_list, int_props, string_props, other_models, protocol_octets_map)
  self.id = id or nil
  self.model = model or ModelInfo.new()
  self.velocity = velocity or nil
  self.role_status_list = role_status_list or {}
  self.int_props = int_props or {}
  self.string_props = string_props or {}
  self.other_models = other_models or {}
  self.protocol_octets_map = protocol_octets_map or {}
end
function MapModelInfo:marshal(os)
  os:marshalInt64(self.id)
  self.model:marshal(os)
  os:marshalInt32(self.velocity)
  os:marshalCompactUInt32(table.getn(self.role_status_list))
  for _, v in ipairs(self.role_status_list) do
    os:marshalInt32(v)
  end
  do
    local _size_ = 0
    for _, _ in pairs(self.int_props) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.int_props) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  do
    local _size_ = 0
    for _, _ in pairs(self.string_props) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.string_props) do
      os:marshalInt32(k)
      os:marshalString(v)
    end
  end
  do
    local _size_ = 0
    for _, _ in pairs(self.other_models) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.other_models) do
      os:marshalInt32(k)
      v:marshal(os)
    end
  end
  local _size_ = 0
  for _, _ in pairs(self.protocol_octets_map) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.protocol_octets_map) do
    os:marshalInt32(k)
    os:marshalOctets(v)
  end
end
function MapModelInfo:unmarshal(os)
  self.id = os:unmarshalInt64()
  self.model = ModelInfo.new()
  self.model:unmarshal(os)
  self.velocity = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.role_status_list, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.int_props[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalString()
    self.string_props[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.pubdata.ModelInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.other_models[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalOctets()
    self.protocol_octets_map[k] = v
  end
end
return MapModelInfo
