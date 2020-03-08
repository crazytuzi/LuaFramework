local OctetsStream = require("netio.OctetsStream")
local FighterStatus = require("netio.protocol.mzm.gsp.fight.FighterStatus")
local PlaySkill = class("PlaySkill")
PlaySkill.NORMAL = 0
PlaySkill.LIAN_XIE_JI = 1
PlaySkill.LIAN_JI = 2
PlaySkill.ZHUI_JI = 3
PlaySkill.DEATH_TRIGGER = 4
PlaySkill.DEATH_BOOMING = 5
PlaySkill.SKILL_CAUSING_DEATH = 6
PlaySkill.SKILL_COUNTER_ATTACK = 7
PlaySkill.EXTRA_LIAN_XIE_JI_TIGGER_ID = 501
PlaySkill.EXTRA_LIAN_XIE_JI_CFG_ID = 502
function PlaySkill:ctor(fighterid, skill, skillplayType, extra, releaser, afterReleaser, targets, status_map, hitAgain_map, protect_map, influenceMap, deathfighter2Skills)
  self.fighterid = fighterid or nil
  self.skill = skill or nil
  self.skillplayType = skillplayType or nil
  self.extra = extra or {}
  self.releaser = releaser or FighterStatus.new()
  self.afterReleaser = afterReleaser or FighterStatus.new()
  self.targets = targets or {}
  self.status_map = status_map or {}
  self.hitAgain_map = hitAgain_map or {}
  self.protect_map = protect_map or {}
  self.influenceMap = influenceMap or {}
  self.deathfighter2Skills = deathfighter2Skills or {}
end
function PlaySkill:marshal(os)
  os:marshalInt32(self.fighterid)
  os:marshalInt32(self.skill)
  os:marshalInt32(self.skillplayType)
  do
    local _size_ = 0
    for _, _ in pairs(self.extra) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.extra) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  self.releaser:marshal(os)
  self.afterReleaser:marshal(os)
  os:marshalCompactUInt32(table.getn(self.targets))
  for _, v in ipairs(self.targets) do
    os:marshalInt32(v)
  end
  do
    local _size_ = 0
    for _, _ in pairs(self.status_map) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.status_map) do
      os:marshalInt32(k)
      v:marshal(os)
    end
  end
  do
    local _size_ = 0
    for _, _ in pairs(self.hitAgain_map) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.hitAgain_map) do
      os:marshalInt32(k)
      v:marshal(os)
    end
  end
  do
    local _size_ = 0
    for _, _ in pairs(self.protect_map) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.protect_map) do
      os:marshalInt32(k)
      v:marshal(os)
    end
  end
  do
    local _size_ = 0
    for _, _ in pairs(self.influenceMap) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.influenceMap) do
      os:marshalInt32(k)
      v:marshal(os)
    end
  end
  local _size_ = 0
  for _, _ in pairs(self.deathfighter2Skills) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.deathfighter2Skills) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function PlaySkill:unmarshal(os)
  self.fighterid = os:unmarshalInt32()
  self.skill = os:unmarshalInt32()
  self.skillplayType = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.extra[k] = v
  end
  self.releaser = FighterStatus.new()
  self.releaser:unmarshal(os)
  self.afterReleaser = FighterStatus.new()
  self.afterReleaser:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.targets, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.fight.AttackResult")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.status_map[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.fight.HitAgain")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.hitAgain_map[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.fight.Protect")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.protect_map[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.fight.InfluenceOther")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.influenceMap[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.fight.Skillids")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.deathfighter2Skills[k] = v
  end
end
return PlaySkill
