local SSyncRoleFightProp = class("SSyncRoleFightProp")
SSyncRoleFightProp.TYPEID = 12586017
function SSyncRoleFightProp:ctor(fightPropMap)
  self.id = 12586017
  self.fightPropMap = fightPropMap or {}
end
function SSyncRoleFightProp:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.fightPropMap) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.fightPropMap) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SSyncRoleFightProp:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.fightPropMap[k] = v
  end
end
function SSyncRoleFightProp:sizepolicy(size)
  return size <= 65535
end
return SSyncRoleFightProp
