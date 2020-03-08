local OctetsStream = require("netio.OctetsStream")
local MapEntityExtraInfo = class("MapEntityExtraInfo")
function MapEntityExtraInfo:ctor(int_extra_infos, long_extra_infos, string_extra_infos)
  self.int_extra_infos = int_extra_infos or {}
  self.long_extra_infos = long_extra_infos or {}
  self.string_extra_infos = string_extra_infos or {}
end
function MapEntityExtraInfo:marshal(os)
  do
    local _size_ = 0
    for _, _ in pairs(self.int_extra_infos) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.int_extra_infos) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  do
    local _size_ = 0
    for _, _ in pairs(self.long_extra_infos) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.long_extra_infos) do
      os:marshalInt32(k)
      os:marshalInt64(v)
    end
  end
  local _size_ = 0
  for _, _ in pairs(self.string_extra_infos) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.string_extra_infos) do
    os:marshalInt32(k)
    os:marshalOctets(v)
  end
end
function MapEntityExtraInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.int_extra_infos[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt64()
    self.long_extra_infos[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalOctets()
    self.string_extra_infos[k] = v
  end
end
return MapEntityExtraInfo
