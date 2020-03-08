local CTransferStrengthLevel = class("CTransferStrengthLevel")
CTransferStrengthLevel.TYPEID = 12584836
function CTransferStrengthLevel:ctor(uuids)
  self.id = 12584836
  self.uuids = uuids or {}
end
function CTransferStrengthLevel:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.uuids) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, _ in pairs(self.uuids) do
    os:marshalInt64(k)
  end
end
function CTransferStrengthLevel:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    self.uuids[v] = v
  end
end
function CTransferStrengthLevel:sizepolicy(size)
  return size <= 65535
end
return CTransferStrengthLevel
