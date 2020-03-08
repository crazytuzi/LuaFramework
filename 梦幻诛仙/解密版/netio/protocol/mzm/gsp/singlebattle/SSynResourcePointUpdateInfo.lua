local SSynResourcePointUpdateInfo = class("SSynResourcePointUpdateInfo")
SSynResourcePointUpdateInfo.TYPEID = 12621588
SSynResourcePointUpdateInfo.REASON_JOIN = 0
SSynResourcePointUpdateInfo.REASON_FIGHT = 1
SSynResourcePointUpdateInfo.EXTRA_INFO_TYPE_WINNER_ID = 0
SSynResourcePointUpdateInfo.EXTRA_INFO_TYPE_LOSER_ID = 1
function SSynResourcePointUpdateInfo:ctor(reason, resource_point_update_infos, long_extra_infos)
  self.id = 12621588
  self.reason = reason or nil
  self.resource_point_update_infos = resource_point_update_infos or {}
  self.long_extra_infos = long_extra_infos or {}
end
function SSynResourcePointUpdateInfo:marshal(os)
  os:marshalUInt8(self.reason)
  do
    local _size_ = 0
    for _, _ in pairs(self.resource_point_update_infos) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.resource_point_update_infos) do
      os:marshalInt64(k)
      os:marshalInt32(v)
    end
  end
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
function SSynResourcePointUpdateInfo:unmarshal(os)
  self.reason = os:unmarshalUInt8()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local v = os:unmarshalInt32()
    self.resource_point_update_infos[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt64()
    self.long_extra_infos[k] = v
  end
end
function SSynResourcePointUpdateInfo:sizepolicy(size)
  return size <= 65535
end
return SSynResourcePointUpdateInfo
