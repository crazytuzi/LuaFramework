local SNewSurpriseGraphNotice = class("SNewSurpriseGraphNotice")
SNewSurpriseGraphNotice.TYPEID = 12592161
function SNewSurpriseGraphNotice:ctor(newGraphIds)
  self.id = 12592161
  self.newGraphIds = newGraphIds or {}
end
function SNewSurpriseGraphNotice:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.newGraphIds) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, _ in pairs(self.newGraphIds) do
    os:marshalInt32(k)
  end
end
function SNewSurpriseGraphNotice:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.newGraphIds[v] = v
  end
end
function SNewSurpriseGraphNotice:sizepolicy(size)
  return size <= 65535
end
return SNewSurpriseGraphNotice
