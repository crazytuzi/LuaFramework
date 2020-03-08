local OctetsStream = require("netio.OctetsStream")
local AdulthoodInfo = class("AdulthoodInfo")
function AdulthoodInfo:ctor(occupation, aptitudeInitMap, useAptitudeItemCount, useGrowthItemCount, occupationSkill2Value, fightSkills, skillBookSkills, specialSkillid, propSet, potentialPoint, hp, mp, grow, unLockSkillPosNum, propMap, character, level, equipItem, equipPetItem)
  self.occupation = occupation or nil
  self.aptitudeInitMap = aptitudeInitMap or {}
  self.useAptitudeItemCount = useAptitudeItemCount or nil
  self.useGrowthItemCount = useGrowthItemCount or nil
  self.occupationSkill2Value = occupationSkill2Value or {}
  self.fightSkills = fightSkills or {}
  self.skillBookSkills = skillBookSkills or {}
  self.specialSkillid = specialSkillid or nil
  self.propSet = propSet or {}
  self.potentialPoint = potentialPoint or nil
  self.hp = hp or nil
  self.mp = mp or nil
  self.grow = grow or nil
  self.unLockSkillPosNum = unLockSkillPosNum or nil
  self.propMap = propMap or {}
  self.character = character or nil
  self.level = level or nil
  self.equipItem = equipItem or {}
  self.equipPetItem = equipPetItem or {}
end
function AdulthoodInfo:marshal(os)
  os:marshalInt32(self.occupation)
  do
    local _size_ = 0
    for _, _ in pairs(self.aptitudeInitMap) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.aptitudeInitMap) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  os:marshalInt32(self.useAptitudeItemCount)
  os:marshalInt32(self.useGrowthItemCount)
  do
    local _size_ = 0
    for _, _ in pairs(self.occupationSkill2Value) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.occupationSkill2Value) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  os:marshalCompactUInt32(table.getn(self.fightSkills))
  for _, v in ipairs(self.fightSkills) do
    os:marshalInt32(v)
  end
  os:marshalCompactUInt32(table.getn(self.skillBookSkills))
  for _, v in ipairs(self.skillBookSkills) do
    os:marshalInt32(v)
  end
  os:marshalInt32(self.specialSkillid)
  do
    local _size_ = 0
    for _, _ in pairs(self.propSet) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.propSet) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  os:marshalInt32(self.potentialPoint)
  os:marshalInt32(self.hp)
  os:marshalInt32(self.mp)
  os:marshalFloat(self.grow)
  os:marshalInt32(self.unLockSkillPosNum)
  do
    local _size_ = 0
    for _, _ in pairs(self.propMap) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.propMap) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  os:marshalInt32(self.character)
  os:marshalInt32(self.level)
  do
    local _size_ = 0
    for _, _ in pairs(self.equipItem) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.equipItem) do
      os:marshalInt32(k)
      v:marshal(os)
    end
  end
  local _size_ = 0
  for _, _ in pairs(self.equipPetItem) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.equipPetItem) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function AdulthoodInfo:unmarshal(os)
  self.occupation = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.aptitudeInitMap[k] = v
  end
  self.useAptitudeItemCount = os:unmarshalInt32()
  self.useGrowthItemCount = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.occupationSkill2Value[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.fightSkills, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.skillBookSkills, v)
  end
  self.specialSkillid = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.propSet[k] = v
  end
  self.potentialPoint = os:unmarshalInt32()
  self.hp = os:unmarshalInt32()
  self.mp = os:unmarshalInt32()
  self.grow = os:unmarshalFloat()
  self.unLockSkillPosNum = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.propMap[k] = v
  end
  self.character = os:unmarshalInt32()
  self.level = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.item.ItemInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.equipItem[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.item.ItemInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.equipPetItem[k] = v
  end
end
return AdulthoodInfo
