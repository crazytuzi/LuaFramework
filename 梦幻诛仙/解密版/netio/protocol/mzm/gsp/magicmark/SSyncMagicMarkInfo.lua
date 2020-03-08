local SSyncMagicMarkInfo = class("SSyncMagicMarkInfo")
SSyncMagicMarkInfo.TYPEID = 12609549
function SSyncMagicMarkInfo:ctor(dressedMagicMarkType, magicMarkInfoMap, effectPropMagicType)
  self.id = 12609549
  self.dressedMagicMarkType = dressedMagicMarkType or nil
  self.magicMarkInfoMap = magicMarkInfoMap or {}
  self.effectPropMagicType = effectPropMagicType or nil
end
function SSyncMagicMarkInfo:marshal(os)
  os:marshalInt32(self.dressedMagicMarkType)
  do
    local _size_ = 0
    for _, _ in pairs(self.magicMarkInfoMap) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.magicMarkInfoMap) do
      os:marshalInt32(k)
      os:marshalInt64(v)
    end
  end
  os:marshalInt32(self.effectPropMagicType)
end
function SSyncMagicMarkInfo:unmarshal(os)
  self.dressedMagicMarkType = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt64()
    self.magicMarkInfoMap[k] = v
  end
  self.effectPropMagicType = os:unmarshalInt32()
end
function SSyncMagicMarkInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncMagicMarkInfo
