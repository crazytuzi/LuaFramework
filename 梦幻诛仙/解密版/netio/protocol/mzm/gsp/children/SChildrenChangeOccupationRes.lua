local SChildrenChangeOccupationRes = class("SChildrenChangeOccupationRes")
SChildrenChangeOccupationRes.TYPEID = 12609413
function SChildrenChangeOccupationRes:ctor(childrenid, occupation, skill2lv, fightSkills)
  self.id = 12609413
  self.childrenid = childrenid or nil
  self.occupation = occupation or nil
  self.skill2lv = skill2lv or {}
  self.fightSkills = fightSkills or {}
end
function SChildrenChangeOccupationRes:marshal(os)
  os:marshalInt64(self.childrenid)
  os:marshalInt32(self.occupation)
  do
    local _size_ = 0
    for _, _ in pairs(self.skill2lv) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.skill2lv) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  os:marshalCompactUInt32(table.getn(self.fightSkills))
  for _, v in ipairs(self.fightSkills) do
    os:marshalInt32(v)
  end
end
function SChildrenChangeOccupationRes:unmarshal(os)
  self.childrenid = os:unmarshalInt64()
  self.occupation = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.skill2lv[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.fightSkills, v)
  end
end
function SChildrenChangeOccupationRes:sizepolicy(size)
  return size <= 65535
end
return SChildrenChangeOccupationRes
