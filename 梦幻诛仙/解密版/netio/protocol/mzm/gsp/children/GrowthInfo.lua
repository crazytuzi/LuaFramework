local OctetsStream = require("netio.OctetsStream")
local GrowthInfo = class("GrowthInfo")
function GrowthInfo:ctor(grow_type, growth_time, int_parameter_map, string_parameter_map)
  self.grow_type = grow_type or nil
  self.growth_time = growth_time or nil
  self.int_parameter_map = int_parameter_map or {}
  self.string_parameter_map = string_parameter_map or {}
end
function GrowthInfo:marshal(os)
  os:marshalInt32(self.grow_type)
  os:marshalInt64(self.growth_time)
  do
    local _size_ = 0
    for _, _ in pairs(self.int_parameter_map) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.int_parameter_map) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  local _size_ = 0
  for _, _ in pairs(self.string_parameter_map) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.string_parameter_map) do
    os:marshalInt32(k)
    os:marshalOctets(v)
  end
end
function GrowthInfo:unmarshal(os)
  self.grow_type = os:unmarshalInt32()
  self.growth_time = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.int_parameter_map[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalOctets()
    self.string_parameter_map[k] = v
  end
end
return GrowthInfo
