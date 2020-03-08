local SSyncPetFightSkill = class("SSyncPetFightSkill")
SSyncPetFightSkill.TYPEID = 12590704
function SSyncPetFightSkill:ctor(pet2skill)
  self.id = 12590704
  self.pet2skill = pet2skill or {}
end
function SSyncPetFightSkill:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.pet2skill) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.pet2skill) do
    os:marshalInt64(k)
    os:marshalInt32(v)
  end
end
function SSyncPetFightSkill:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local v = os:unmarshalInt32()
    self.pet2skill[k] = v
  end
end
function SSyncPetFightSkill:sizepolicy(size)
  return size <= 65535
end
return SSyncPetFightSkill
