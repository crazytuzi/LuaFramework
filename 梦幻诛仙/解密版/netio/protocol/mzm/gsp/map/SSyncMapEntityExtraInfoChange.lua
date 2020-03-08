local MapEntityExtraInfo = require("netio.protocol.mzm.gsp.map.MapEntityExtraInfo")
local SSyncMapEntityExtraInfoChange = class("SSyncMapEntityExtraInfoChange")
SSyncMapEntityExtraInfoChange.TYPEID = 12590947
function SSyncMapEntityExtraInfoChange:ctor(entity_type, instanceid, extra_info, remove_extra_info_keys)
  self.id = 12590947
  self.entity_type = entity_type or nil
  self.instanceid = instanceid or nil
  self.extra_info = extra_info or MapEntityExtraInfo.new()
  self.remove_extra_info_keys = remove_extra_info_keys or {}
end
function SSyncMapEntityExtraInfoChange:marshal(os)
  os:marshalInt32(self.entity_type)
  os:marshalInt64(self.instanceid)
  self.extra_info:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.remove_extra_info_keys) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, _ in pairs(self.remove_extra_info_keys) do
    os:marshalInt32(k)
  end
end
function SSyncMapEntityExtraInfoChange:unmarshal(os)
  self.entity_type = os:unmarshalInt32()
  self.instanceid = os:unmarshalInt64()
  self.extra_info = MapEntityExtraInfo.new()
  self.extra_info:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.remove_extra_info_keys[v] = v
  end
end
function SSyncMapEntityExtraInfoChange:sizepolicy(size)
  return size <= 65535
end
return SSyncMapEntityExtraInfoChange
