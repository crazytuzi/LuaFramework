local SSynPlayFeiShengEffectInfo = class("SSynPlayFeiShengEffectInfo")
SSynPlayFeiShengEffectInfo.TYPEID = 12614179
function SSynPlayFeiShengEffectInfo:ctor(effect_info)
  self.id = 12614179
  self.effect_info = effect_info or {}
end
function SSynPlayFeiShengEffectInfo:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.effect_info) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.effect_info) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SSynPlayFeiShengEffectInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.effect_info[k] = v
  end
end
function SSynPlayFeiShengEffectInfo:sizepolicy(size)
  return size <= 65535
end
return SSynPlayFeiShengEffectInfo
