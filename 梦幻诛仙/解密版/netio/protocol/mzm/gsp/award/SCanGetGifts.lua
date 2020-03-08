local SCanGetGifts = class("SCanGetGifts")
SCanGetGifts.TYPEID = 12583448
function SCanGetGifts:ctor(useTypeInfo)
  self.id = 12583448
  self.useTypeInfo = useTypeInfo or {}
end
function SCanGetGifts:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.useTypeInfo) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.useTypeInfo) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SCanGetGifts:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.useTypeInfo[k] = v
  end
end
function SCanGetGifts:sizepolicy(size)
  return size <= 65535
end
return SCanGetGifts
