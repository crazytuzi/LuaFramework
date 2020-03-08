local SSynJifen = class("SSynJifen")
SSynJifen.TYPEID = 12585473
function SSynJifen:ctor(jifen)
  self.id = 12585473
  self.jifen = jifen or {}
end
function SSynJifen:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.jifen) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.jifen) do
    os:marshalInt32(k)
    os:marshalInt64(v)
  end
end
function SSynJifen:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt64()
    self.jifen[k] = v
  end
end
function SSynJifen:sizepolicy(size)
  return size <= 65535
end
return SSynJifen
