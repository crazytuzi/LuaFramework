local SSynResourcePointInfo = class("SSynResourcePointInfo")
SSynResourcePointInfo.TYPEID = 12621589
function SSynResourcePointInfo:ctor(resource_point_infos)
  self.id = 12621589
  self.resource_point_infos = resource_point_infos or {}
end
function SSynResourcePointInfo:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.resource_point_infos) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.resource_point_infos) do
    os:marshalInt64(k)
    os:marshalInt32(v)
  end
end
function SSynResourcePointInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local v = os:unmarshalInt32()
    self.resource_point_infos[k] = v
  end
end
function SSynResourcePointInfo:sizepolicy(size)
  return size <= 65535
end
return SSynResourcePointInfo
