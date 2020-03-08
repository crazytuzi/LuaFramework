local OctetsStream = require("netio.OctetsStream")
local PetFightSkillInfo = class("PetFightSkillInfo")
function PetFightSkillInfo:ctor(skills, pet2skill)
  self.skills = skills or {}
  self.pet2skill = pet2skill or {}
end
function PetFightSkillInfo:marshal(os)
  do
    local _size_ = 0
    for _, _ in pairs(self.skills) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, _ in pairs(self.skills) do
      os:marshalInt32(k)
    end
  end
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
function PetFightSkillInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.skills[v] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local v = os:unmarshalInt32()
    self.pet2skill[k] = v
  end
end
return PetFightSkillInfo
