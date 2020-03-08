local SMenPaiSkillAutoLevelUpRes = class("SMenPaiSkillAutoLevelUpRes")
SMenPaiSkillAutoLevelUpRes.TYPEID = 12591629
function SMenPaiSkillAutoLevelUpRes:ctor(skillMap, useSilver)
  self.id = 12591629
  self.skillMap = skillMap or {}
  self.useSilver = useSilver or nil
end
function SMenPaiSkillAutoLevelUpRes:marshal(os)
  do
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
  os:marshalInt32(self.useSilver)
end
function SMenPaiSkillAutoLevelUpRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.skillMap[k] = v
  end
  self.useSilver = os:unmarshalInt32()
end
function SMenPaiSkillAutoLevelUpRes:sizepolicy(size)
  return size <= 65535
end
return SMenPaiSkillAutoLevelUpRes
