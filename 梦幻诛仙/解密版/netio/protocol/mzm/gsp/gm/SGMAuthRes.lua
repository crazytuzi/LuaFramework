local SGMAuthRes = class("SGMAuthRes")
SGMAuthRes.TYPEID = 12585729
function SGMAuthRes:ctor(authset)
  self.id = 12585729
  self.authset = authset or {}
end
function SGMAuthRes:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.authset) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, _ in pairs(self.authset) do
    os:marshalInt32(k)
  end
end
function SGMAuthRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.authset[v] = v
  end
end
function SGMAuthRes:sizepolicy(size)
  return size <= 65535
end
return SGMAuthRes
