local SNotifyDistribution = class("SNotifyDistribution")
SNotifyDistribution.TYPEID = 12615682
function SNotifyDistribution:ctor(roles, activity_id)
  self.id = 12615682
  self.roles = roles or {}
  self.activity_id = activity_id or nil
end
function SNotifyDistribution:marshal(os)
  do
    local _size_ = 0
    for _, _ in pairs(self.roles) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.roles) do
      os:marshalInt64(k)
      os:marshalOctets(v)
    end
  end
  os:marshalInt32(self.activity_id)
end
function SNotifyDistribution:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local v = os:unmarshalOctets()
    self.roles[k] = v
  end
  self.activity_id = os:unmarshalInt32()
end
function SNotifyDistribution:sizepolicy(size)
  return size <= 65535
end
return SNotifyDistribution
