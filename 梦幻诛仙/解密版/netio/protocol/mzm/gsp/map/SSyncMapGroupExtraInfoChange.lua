local SSyncMapGroupExtraInfoChange = class("SSyncMapGroupExtraInfoChange")
SSyncMapGroupExtraInfoChange.TYPEID = 12590946
function SSyncMapGroupExtraInfoChange:ctor(group_type, groupid, extra_infos, remove_extra_info_keys)
  self.id = 12590946
  self.group_type = group_type or nil
  self.groupid = groupid or nil
  self.extra_infos = extra_infos or {}
  self.remove_extra_info_keys = remove_extra_info_keys or {}
end
function SSyncMapGroupExtraInfoChange:marshal(os)
  os:marshalInt32(self.group_type)
  os:marshalInt64(self.groupid)
  do
    local _size_ = 0
    for _, _ in pairs(self.extra_infos) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.extra_infos) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  local _size_ = 0
  for _, _ in pairs(self.remove_extra_info_keys) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, _ in pairs(self.remove_extra_info_keys) do
    os:marshalInt32(k)
  end
end
function SSyncMapGroupExtraInfoChange:unmarshal(os)
  self.group_type = os:unmarshalInt32()
  self.groupid = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.extra_infos[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.remove_extra_info_keys[v] = v
  end
end
function SSyncMapGroupExtraInfoChange:sizepolicy(size)
  return size <= 65535
end
return SSyncMapGroupExtraInfoChange
