local SSyncServerMergeHistory = class("SSyncServerMergeHistory")
SSyncServerMergeHistory.TYPEID = 12582916
function SSyncServerMergeHistory:ctor(zoneids)
  self.id = 12582916
  self.zoneids = zoneids or {}
end
function SSyncServerMergeHistory:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.zoneids) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, _ in pairs(self.zoneids) do
    os:marshalInt32(k)
  end
end
function SSyncServerMergeHistory:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.zoneids[v] = v
  end
end
function SSyncServerMergeHistory:sizepolicy(size)
  return size <= 65535
end
return SSyncServerMergeHistory
