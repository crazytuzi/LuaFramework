local SSyncTempSkillListAdd = class("SSyncTempSkillListAdd")
SSyncTempSkillListAdd.TYPEID = 12591627
function SSyncTempSkillListAdd:ctor(skillMap)
  self.id = 12591627
  self.skillMap = skillMap or {}
end
function SSyncTempSkillListAdd:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.skillMap) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.skillMap) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SSyncTempSkillListAdd:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.skillMap[k] = v
  end
end
function SSyncTempSkillListAdd:sizepolicy(size)
  return size <= 65535
end
return SSyncTempSkillListAdd
