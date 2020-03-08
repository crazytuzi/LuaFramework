local OctetsStream = require("netio.OctetsStream")
local AutoFightInfo = class("AutoFightInfo")
function AutoFightInfo:ctor(auto_state, role_default_skill, pet_default_skills, child_default_skills)
  self.auto_state = auto_state or nil
  self.role_default_skill = role_default_skill or nil
  self.pet_default_skills = pet_default_skills or {}
  self.child_default_skills = child_default_skills or {}
end
function AutoFightInfo:marshal(os)
  os:marshalInt32(self.auto_state)
  os:marshalInt32(self.role_default_skill)
  do
    local _size_ = 0
    for _, _ in pairs(self.pet_default_skills) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.pet_default_skills) do
      os:marshalInt64(k)
      os:marshalInt32(v)
    end
  end
  local _size_ = 0
  for _, _ in pairs(self.child_default_skills) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.child_default_skills) do
    os:marshalInt64(k)
    os:marshalInt32(v)
  end
end
function AutoFightInfo:unmarshal(os)
  self.auto_state = os:unmarshalInt32()
  self.role_default_skill = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local v = os:unmarshalInt32()
    self.pet_default_skills[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local v = os:unmarshalInt32()
    self.child_default_skills[k] = v
  end
end
return AutoFightInfo
